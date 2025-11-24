//
//  DolphinPathEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/23/25.
//

import Foundation

// MARK: - Dolphin Path Visualization Entity
class DolphinPathEntity: EntityFullWidth {
    private var cachedPath: [String]?
    private var cachedWidth: Int = 0
    private let path: [[Double]]
    private let baseY: Int

    init(name: String, position: Position3D, path: [[Double]]) {
        self.path = path
        self.baseY = position.y
        super.init(name: name, type: .waterline, shape: ["."], position: position)

        defaultColor = .magenta
        // Path visualization doesn't move
    }

    override func getShape(for width: Int) -> [String] {
        // Use cached path if available and width hasn't changed
        if let cached = cachedPath, cachedWidth == width {
            return cached
        }

        // Calculate the y positions for each step in the path
        var yPositions: [Int] = []
        var currentY = baseY
        yPositions.append(Int(baseY))  // Include starting position

        // Calculate y for each path step
        for step in path {
            if step.count >= 3 {
                let dy = step[2]
                currentY += Int(dy)
                yPositions.append(Int(currentY))
            }
        }

        // Find the min and max y to determine the height needed
        guard let minY = yPositions.min(), let maxY = yPositions.max() else {
            return [String(repeating: ".", count: width)]
        }

        let pathHeight = maxY - minY + 1
        var pathLines: [String] = Array(
            repeating: String(repeating: " ", count: width), count: pathHeight)

        // Mark only the path positions (not entire rows) to create a sine wave pattern
        for stepY in yPositions {
            let relativeY = stepY - minY
            if relativeY >= 0 && relativeY < pathHeight {
                // Mark this specific y position across the full width
                let char: Character = "·"
                let filledLine = String(repeating: char, count: width)
                pathLines[relativeY] = filledLine
            }
        }

        // Cache the result
        cachedPath = pathLines
        cachedWidth = width

        return pathLines
    }
}
