//
//  ASCIIRenderer.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Cocoa
import Foundation
import SwiftUI

/// Handles rendering ASCII art for the asciiquarium
class ASCIIRenderer {
    private var font: NSFont
    private var cachedCharacterWidth: CGFloat?
    private var cachedLineHeight: CGFloat?
    private var cachedFontSize: CGFloat?

    init() {
        self.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    }

    // Character dimensions for accurate positioning
    var characterWidth: CGFloat {
        if let cached = cachedCharacterWidth {
            return cached
        }
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let width = sampleString.size(withAttributes: attributes).width
        cachedCharacterWidth = width
        return width
    }

    var lineHeight: CGFloat {
        if let cached = cachedLineHeight {
            return cached
        }
        let height = font.ascender - font.descender + font.leading
        cachedLineHeight = height
        return height
    }

    /// Render the asciiquarium scene
    func renderScene(entities: [AquariumEntity], in bounds: CGRect) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()

        // Create a simple text representation
        var lines: [String] = []
        let height = Int(bounds.height / lineHeight)
        let width = Int(bounds.width / characterWidth)

        // Initialize empty lines
        for _ in 0..<height {
            lines.append(String(repeating: " ", count: width))
        }

        // Add entities to the scene
        for entity in entities {
            let x = Int(entity.position.x / characterWidth)
            let y = Int(entity.position.y / lineHeight)

            if x >= 0 && x < width && y >= 0 && y < height {
                let line = lines[y]
                let startIndex = line.startIndex
                let endIndex = line.index(startIndex, offsetBy: min(x + entity.shape.count, width))
                let before = String(line[startIndex..<line.index(startIndex, offsetBy: x)])
                let after = String(line[endIndex..<line.endIndex])

                lines[y] = before + entity.shape + after
            }
        }

        // Add water surface (3 lines from bottom)
        let surfaceY = max(0, height - 4)
        if surfaceY < height {
            let surfaceLine = String(repeating: "~", count: width)
            lines[surfaceY] = surfaceLine
        }

        // Add bottom border (last line)
        let bottomY = height - 1
        if bottomY >= 0 && bottomY < height {
            let bottomLine = String(repeating: "=", count: width)
            lines[bottomY] = bottomLine
        }

        // Create attributed string
        for (_, line) in lines.enumerated() {
            let attributedLine = NSAttributedString(
                string: line + "\n",
                attributes: [
                    .font: font,
                    .foregroundColor: NSColor.blue,
                ]
            )
            mutableString.append(attributedLine)
        }

        return mutableString
    }

    /// Draw a single character at a specific position
    func drawCharacter(_ character: String, at point: CGPoint, color: NSColor) -> NSAttributedString
    {
        return NSAttributedString(
            string: character,
            attributes: [
                .font: font,
                .foregroundColor: color,
            ]
        )
    }

    // MARK: - Font Metrics Methods

    /// Calculate optimal font size for the given bounds
    func calculateOptimalFontSize(for bounds: CGRect) -> CGFloat {
        // Start with a reasonable base size
        let baseSize: CGFloat = 12.0

        // Calculate how many characters we can fit
        let maxCharactersWidth = Int(bounds.width / (baseSize * 0.6))  // Approximate character width
        let maxCharactersHeight = Int(bounds.height / (baseSize * 1.2))  // Approximate line height

        // Use the smaller dimension to determine font size
        let maxCharacters = min(maxCharactersWidth, maxCharactersHeight)

        // Calculate font size based on available space
        let fontSize = min(baseSize * CGFloat(maxCharacters) / 50.0, 24.0)  // Cap at 24pt
        let finalSize = max(fontSize, 8.0)  // Minimum 8pt

        // Update font if size changed
        if cachedFontSize != finalSize {
            updateFont(size: finalSize)
        }

        return finalSize
    }

    /// Calculate grid width for the given bounds
    func calculateGridWidth(for bounds: CGRect) -> Int {
        return Int(bounds.width / characterWidth)
    }

    /// Calculate grid height for the given bounds
    func calculateGridHeight(for bounds: CGRect) -> Int {
        return Int(bounds.height / lineHeight)
    }

    /// Calculate optimal character grid dimensions that fit perfectly in the given bounds
    func calculateOptimalGridDimensions(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        // Step 1: Find the optimal font size based on height utilization
        var bestFontSize: CGFloat = 8.0
        var bestHeightUtilization: CGFloat = 0.0

        // Try different font sizes to maximize height utilization
        for testSize in stride(from: 8.0, through: 24.0, by: 0.25) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let lineHeight = calculateLineHeight(for: testFont)

            let gridHeight = Int(bounds.height / lineHeight)
            guard gridHeight > 0 else { continue }

            // Calculate height utilization
            let usedHeight = CGFloat(gridHeight) * lineHeight
            let heightUtilization = usedHeight / bounds.height

            // Choose the font size that maximizes height utilization
            if heightUtilization > bestHeightUtilization {
                bestHeightUtilization = heightUtilization
                bestFontSize = testSize
            }
        }

        // Step 2: Calculate width based on the optimal font size
        let optimalFont = NSFont.monospacedSystemFont(ofSize: bestFontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)
        let lineHeight = calculateLineHeight(for: optimalFont)

        // Validate character width and line height
        guard charWidth.isFinite && charWidth > 0 else {
            print("Error: Invalid character width: \(charWidth)")
            return (width: 80, height: 24, fontSize: bestFontSize)
        }

        guard lineHeight.isFinite && lineHeight > 0 else {
            print("Error: Invalid line height: \(lineHeight)")
            return (width: 80, height: 24, fontSize: bestFontSize)
        }

        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        // Ensure we have valid dimensions
        let finalGridWidth = max(1, gridWidth)
        let finalGridHeight = max(1, gridHeight)

        // Log calculated dimensions for debugging
        print("=== ASCIIRenderer Dimension Calculation ===")
        print("Bounds: \(bounds)")
        print("Best font size: \(bestFontSize)")
        print("Character width: \(charWidth)")
        print("Line height: \(lineHeight)")
        print("Raw grid width: \(gridWidth)")
        print("Raw grid height: \(gridHeight)")
        print("Final grid width: \(finalGridWidth)")
        print("Final grid height: \(finalGridHeight)")
        print("Width utilization: \(CGFloat(finalGridWidth) * charWidth / bounds.width * 100)%")
        print("Height utilization: \(CGFloat(finalGridHeight) * lineHeight / bounds.height * 100)%")
        print("==========================================")

        return (width: finalGridWidth, height: finalGridHeight, fontSize: bestFontSize)
    }

    /// Calculate character width for a given font
    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        // Use NSLayoutManager to get the actual space each character takes when rendered
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        // Test with multiple characters to get accurate per-character width
        let testString = "MMMMMMMMMMMMMMMM"  // 16 characters
        let attributedString = NSAttributedString(string: testString, attributes: [.font: font])
        textStorage.setAttributedString(attributedString)

        let usedRect = layoutManager.usedRect(for: textContainer)
        let perCharWidth = usedRect.width / CGFloat(testString.count)

        // Validate the result and fallback to font.maximumAdvancement if invalid
        if perCharWidth.isFinite && perCharWidth > 0 {
            return perCharWidth
        } else {
            print("Warning: NSLayoutManager calculation failed, using font.maximumAdvancement")
            return font.maximumAdvancement.width
        }
    }

    /// Calculate line height for a given font
    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    /// Update font with new size and clear cache
    private func updateFont(size: CGFloat) {
        font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        cachedCharacterWidth = nil
        cachedLineHeight = nil
        cachedFontSize = size
    }
}
