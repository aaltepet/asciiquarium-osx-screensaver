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
        self.font = FontMetrics.shared.createDefaultFont()
        updateCachedDimensions()
    }

    // Character dimensions for accurate positioning using FontMetrics
    var characterWidth: CGFloat {
        if let cached = cachedCharacterWidth {
            return cached
        }
        let width = FontMetrics.shared.calculateCharacterWidth(for: font)
        cachedCharacterWidth = width
        return width
    }

    var lineHeight: CGFloat {
        if let cached = cachedLineHeight {
            return cached
        }
        let height = FontMetrics.shared.calculateLineHeight(for: font)
        cachedLineHeight = height
        return height
    }

    /// Update font with new size and clear cache
    func updateFont(size: CGFloat) {
        font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        updateCachedDimensions()
        cachedFontSize = size
    }

    /// Update font with optimal sizing from FontMetrics
    func updateFontWithOptimalSizing(for bounds: CGRect) {
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)
        updateFont(size: optimalGrid.fontSize)
    }

    /// Update cached dimensions using FontMetrics
    private func updateCachedDimensions() {
        cachedCharacterWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        cachedLineHeight = FontMetrics.shared.calculateLineHeight(for: font)
    }

    /// Validate character dimensions and provide fallback if needed
    private func validateDimensions() -> Bool {
        guard let charWidth = cachedCharacterWidth,
            let lineHeight = cachedLineHeight
        else {
            return false
        }

        return charWidth.isFinite && charWidth > 0 && lineHeight.isFinite && lineHeight > 0
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

    /// Render the asciiquarium scene
    func renderScene(entities: [AquariumEntity], in bounds: CGRect) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()

        // Validate dimensions before proceeding
        guard validateDimensions() else {
            print("Warning: Invalid character dimensions, using fallback")
            updateCachedDimensions()
            return NSAttributedString(string: "Error: Invalid font dimensions")
        }

        // Create a simple text representation using cached character dimensions
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
}
