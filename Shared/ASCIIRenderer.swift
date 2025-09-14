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

    /// Update font with new size and clear cache
    private func updateFont(size: CGFloat) {
        font = NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        cachedCharacterWidth = nil
        cachedLineHeight = nil
        cachedFontSize = size
    }
}
