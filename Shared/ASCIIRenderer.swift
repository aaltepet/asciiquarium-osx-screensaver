//
//  ASCIIRenderer.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation
import SwiftUI

/// Handles rendering ASCII art for the asciiquarium
class ASCIIRenderer {
    private let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    
    /// Render the asciiquarium scene
    func renderScene(entities: [AquariumEntity], in bounds: CGRect) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()
        
        // Create a simple text representation
        var lines: [String] = []
        let height = Int(bounds.height / 20) // Approximate lines based on font size
        let width = Int(bounds.width / 8)   // Approximate characters based on font size
        
        // Initialize empty lines
        for _ in 0..<height {
            lines.append(String(repeating: " ", count: width))
        }
        
        // Add entities to the scene
        for entity in entities {
            let x = Int(entity.position.x / 8) // Convert to character position
            let y = Int(entity.position.y / 20)
            
            if x >= 0 && x < width && y >= 0 && y < height {
                let line = lines[y]
                let startIndex = line.startIndex
                let endIndex = line.index(startIndex, offsetBy: min(x + entity.shape.count, width))
                let before = String(line[startIndex..<line.index(startIndex, offsetBy: x)])
                let after = String(line[endIndex..<line.endIndex])
                
                lines[y] = before + entity.shape + after
            }
        }
        
        // Add water surface
        let surfaceY = height - 3
        if surfaceY >= 0 && surfaceY < height {
            let surfaceLine = String(repeating: "~", count: width)
            lines[surfaceY] = surfaceLine
        }
        
        // Add bottom border
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
                    .foregroundColor: NSColor.blue
                ]
            )
            mutableString.append(attributedLine)
        }
        
        return mutableString
    }
    
    /// Draw a single character at a specific position
    func drawCharacter(_ character: String, at point: CGPoint, color: NSColor) -> NSAttributedString {
        return NSAttributedString(
            string: character,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
    }
}
