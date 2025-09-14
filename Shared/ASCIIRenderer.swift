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
    func renderScene(entities: [Entity], in bounds: CGRect) -> NSAttributedString {
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

        // Sort entities by depth (z-coordinate) for proper layering
        let sortedEntities = entities.sorted { $0.position.z < $1.position.z }

        // Add entities to the scene
        for entity in sortedEntities {
            let y = Int(CGFloat(entity.position.y) / lineHeight)

            if y >= 0 && y < height {
                // Handle full-width entities
                if entity.isFullWidth {
                    // For full-width entities, generate current shape (allows for dynamic/random generation)
                    if let fullWidthEntity = entity as? EntityFullWidth {
                        let entityShape = fullWidthEntity.getShape(for: width)
                        for (shapeLineIndex, shapeLine) in entityShape.enumerated() {
                            let entityY = y + shapeLineIndex
                            if entityY >= 0 && entityY < height {
                                lines[entityY] = shapeLine
                            }
                        }
                    }
                } else {
                    // Handle regular positioned entities - use shape directly for efficiency
                    let x = Int(CGFloat(entity.position.x) / characterWidth)
                    if x >= 0 && x < width {
                        // Render each line of the entity's shape
                        for (shapeLineIndex, shapeLine) in entity.shape.enumerated() {
                            let entityY = y + shapeLineIndex
                            if entityY >= 0 && entityY < height {
                                let line = lines[entityY]
                                let startIndex = line.startIndex
                                let endIndex = line.index(
                                    startIndex, offsetBy: min(x + shapeLine.count, width))
                                let before = String(
                                    line[startIndex..<line.index(startIndex, offsetBy: x)])
                                let after = String(line[endIndex..<line.endIndex])

                                lines[entityY] = before + shapeLine + after
                            }
                        }
                    }
                }
            }
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
