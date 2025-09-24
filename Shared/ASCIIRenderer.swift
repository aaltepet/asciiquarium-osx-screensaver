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
    func renderScene(entities: [Entity], gridWidth: Int, gridHeight: Int) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()

        // Validate dimensions before proceeding
        guard validateDimensions() else {
            print("Warning: Invalid character dimensions, using fallback")
            updateCachedDimensions()
            return NSAttributedString(string: "Error: Invalid font dimensions")
        }

        // Create a simple text representation using grid dimensions
        var lines: [String] = []

        // Initialize empty lines
        for _ in 0..<gridHeight {
            lines.append(String(repeating: " ", count: gridWidth))
        }

        // Sort entities by depth (z-coordinate) for proper layering
        let sortedEntities = entities.sorted { $0.position.z < $1.position.z }

        // Add entities to the scene (composited with transparency)
        for entity in sortedEntities {
            let y = entity.position.y

            if y >= 0 && y < gridHeight {
                // Handle full-width entities
                if entity.isFullWidth {
                    // Preserve existing behavior for full-width entities (e.g., waterlines): replace entire line
                    if let fullWidthEntity = entity as? EntityFullWidth {
                        let entityShape = fullWidthEntity.getShape(for: gridWidth)
                        for (shapeLineIndex, shapeLine) in entityShape.enumerated() {
                            let entityY = y + shapeLineIndex
                            if entityY >= 0 && entityY < gridHeight {
                                lines[entityY] = shapeLine
                            }
                        }
                    }
                } else {
                    // Handle regular positioned entities - use shape directly for efficiency
                    let x = entity.position.x
                    if x >= 0 && x < gridWidth {
                        // Render each line of the entity's shape
                        for (shapeLineIndex, shapeLine) in entity.shape.enumerated() {
                            let entityY = y + shapeLineIndex
                            if entityY >= 0 && entityY < gridHeight {
                                var line = lines[entityY]
                                let availableWidth = max(0, gridWidth - x)
                                if availableWidth == 0 { continue }
                                let croppedShape = String(shapeLine.prefix(availableWidth))
                                let transparent = entity.transparentChar
                                // If an alphaMask is provided, use it to force opacity for masked pixels
                                let maskLine: String? = {
                                    if let alpha = (entity as? BaseEntity)?.alphaMask,
                                        shapeLineIndex < alpha.count
                                    {
                                        return alpha[shapeLineIndex]
                                    }
                                    return nil
                                }()
                                if transparent == nil && maskLine == nil {
                                    // Original fast path: replace substring
                                    let replaceStart = line.index(line.startIndex, offsetBy: x)
                                    let replaceEnd = line.index(
                                        replaceStart, offsetBy: croppedShape.count)
                                    line.replaceSubrange(
                                        replaceStart..<replaceEnd, with: croppedShape)
                                } else {
                                    // Composite per character, skipping transparent characters
                                    for (i, ch) in croppedShape.enumerated() {
                                        if let t = transparent, ch == t {
                                            // If alpha mask marks this pixel as opaque, draw even if it's a space
                                            if let mask = maskLine, i < mask.count {
                                                let idx = mask.index(mask.startIndex, offsetBy: i)
                                                let maskCh = mask[idx]
                                                if maskCh != " " {
                                                    let targetIdx = line.index(
                                                        line.startIndex, offsetBy: x + i)
                                                    line.replaceSubrange(
                                                        targetIdx...targetIdx, with: String(ch))
                                                }
                                            }
                                            continue
                                        }
                                        let targetIdx = line.index(line.startIndex, offsetBy: x + i)
                                        line.replaceSubrange(
                                            targetIdx...targetIdx, with: String(ch))
                                    }
                                }
                                lines[entityY] = line
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
