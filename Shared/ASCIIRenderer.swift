//
//  ASCIIRenderer.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
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

    /// Map ColorCode to NSColor (upper-case variants are treated as brighter where possible)
    private func nsColor(for code: ColorCode) -> NSColor {
        switch code {
        case .cyan: return NSColor.cyan
        case .cyanBright: return NSColor.systemTeal
        case .red: return NSColor.red
        case .redBright: return NSColor.systemRed
        case .yellow: return NSColor.yellow
        case .yellowBright: return NSColor.systemYellow
        case .blue: return NSColor.blue
        case .blueBright: return NSColor.systemBlue
        case .green: return NSColor.green
        case .greenBright: return NSColor.systemGreen
        case .magenta: return NSColor.magenta
        case .magentaBright: return NSColor.systemPink
        case .white: return NSColor.white
        case .whiteBright: return NSColor.white
        case .black: return NSColor.black
        case .blackBright: return NSColor.darkGray
        }
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
        // Parallel color grid matching text grid. Nil means use fallback color.
        var colorGrid: [[ColorCode?]] = Array(
            repeating: Array(repeating: nil, count: gridWidth), count: gridHeight)

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
                                // Apply a flat color for full-width lines if provided
                                let defaultColor = (entity as? BaseEntity)?.defaultColor
                                if let def = defaultColor {
                                    let rowCount = min(gridWidth, shapeLine.count)
                                    for i in 0..<rowCount {
                                        colorGrid[entityY][i] = def
                                    }
                                }
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
                                let baseEntity = entity as? BaseEntity

                                // Get color mask line for opacity control
                                let colorMaskLine: String? = {
                                    if let cm = baseEntity?.colorMask,
                                        shapeLineIndex < cm.count
                                    {
                                        return cm[shapeLineIndex]
                                    }
                                    return nil
                                }()

                                // Composite per character, respecting transparency and color mask
                                for (i, ch) in croppedShape.enumerated() {
                                    // Determine if this pixel should be drawn based on colorMask opacity
                                    var shouldDraw: Bool

                                    if let cmLine = colorMaskLine, i < cmLine.count {
                                        // ColorMask controls opacity: space = transparent, non-space = opaque
                                        let idx = cmLine.index(cmLine.startIndex, offsetBy: i)
                                        let maskCh = cmLine[idx]
                                        shouldDraw = (maskCh != " ")
                                    } else {
                                        // Fall back to transparentChar logic if no colorMask
                                        let isTransparentChar =
                                            (transparent != nil && ch == transparent!)
                                        shouldDraw = !isTransparentChar
                                    }

                                    if shouldDraw {
                                        let targetX = x + i
                                        // Bounds check: ensure we don't access out-of-bounds indices
                                        guard
                                            targetX >= 0 && targetX < gridWidth
                                                && targetX < line.count
                                        else { continue }

                                        let targetIdx = line.index(
                                            line.startIndex, offsetBy: targetX)
                                        line.replaceSubrange(
                                            targetIdx...targetIdx, with: String(ch))

                                        // Determine color for this pixel
                                        var pixelColor: ColorCode? = nil
                                        if let cm = (entity as? BaseEntity)?.colorMask,
                                            shapeLineIndex < cm.count
                                        {
                                            let cmLine = cm[shapeLineIndex]
                                            if i < cmLine.count {
                                                let cIdx = cmLine.index(
                                                    cmLine.startIndex, offsetBy: i)
                                                let colorCh = cmLine[cIdx]
                                                if colorCh != " " {
                                                    if let code = ColorCode(rawValue: colorCh) {
                                                        pixelColor = code
                                                    }
                                                }
                                            }
                                        }
                                        if pixelColor == nil {
                                            pixelColor = (entity as? BaseEntity)?.defaultColor
                                        }
                                        colorGrid[entityY][targetX] = pixelColor
                                    }
                                }
                                lines[entityY] = line
                            }
                        }
                    }
                }
            }
        }

        // Create attributed string with per-character colors
        for y in 0..<lines.count {
            let line = lines[y]
            // Iterate characters and append with color
            for (x, ch) in line.enumerated() {
                let pixelNSColor = colorGrid[y][x].map { nsColor(for: $0) } ?? NSColor.blue
                let attr = drawCharacter(String(ch), at: .zero, color: pixelNSColor)
                mutableString.append(attr)
            }
            // Append newline
            let nl = NSAttributedString(
                string: "\n", attributes: [.font: font, .foregroundColor: NSColor.blue])
            mutableString.append(nl)
        }

        return mutableString
    }
}
