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
    private let baseY: Double  // Original starting y position (dolphin3Y = 8.0)
    private let dolphinStartX: Int  // The x position where dolphin3 (offset 0) starts

    init(name: String, position: Position3D, path: [[Double]], baseY: Double, dolphinStartX: Int) {
        self.path = path
        self.baseY = baseY  // Original starting y (8.0), not the minY
        self.dolphinStartX = dolphinStartX
        // Calculate minY to position the entity correctly
        var currentY = baseY
        var minY = currentY
        for step in path {
            if step.count >= 3 {
                let dy = step[2]
                currentY += dy
                minY = min(minY, currentY)
            }
        }
        // Position at minY so the visualization aligns correctly
        let adjustedPosition = Position3D(position.x, Int(minY), position.z)
        super.init(name: name, type: .waterline, shape: ["."], position: adjustedPosition)

        defaultColor = .magenta
        // Path visualization doesn't move
    }

    override func getShape(for width: Int) -> [String] {
        // Use cached path if available and width hasn't changed
        if let cached = cachedPath, cachedWidth == width {
            return cached
        }

        // Step 1: Simulate EXACT frame-by-frame movement of dolphin3 (pathOffset=0)
        // Match the dolphin's exact logic: frameCount determines stepIndex, fractional accumulation
        var fractionalX = 0.0
        var fractionalY = 0.0
        var currentY = baseY  // Starting y position (dolphin3's initial y)
        var currentX = 0.0  // Starting x position (relative to dolphinStartX)
        var minY = currentY
        var maxY = currentY

        let deltaTime = 1.0 / 30.0  // 30 FPS
        var pathPoints: [(x: Double, y: Double)] = [(currentX, currentY)]  // Starting position
        var uniqueYValues = Set<Int>()
        uniqueYValues.insert(Int(currentY))

        // Simulate enough frames to complete at least one full path cycle
        // Path has 36 steps, simulate a few cycles to be safe
        let framesToSimulate = path.count * 3

        for frameCount in 0..<framesToSimulate {
            // EXACT same logic as dolphin: stepIndex = (frameCount + pathOffset) % path.count
            // For dolphin3, pathOffset = 0
            let stepIndex = frameCount % path.count

            guard stepIndex < path.count else { continue }
            let step = path[stepIndex]
            guard step.count >= 4 else { continue }

            let stepSpeed = step[0]
            let dx = step[1]
            let dy = step[2]

            // EXACT same movement calculation as dolphin
            let gridSpeed = stepSpeed * 30.0
            fractionalX += gridSpeed * dx * deltaTime
            fractionalY += gridSpeed * dy * deltaTime

            let moveX = Int(fractionalX)
            let moveY = Int(fractionalY)
            fractionalX -= Double(moveX)
            fractionalY -= Double(moveY)

            // Update position
            currentX += Double(moveX)
            currentY += Double(moveY)

            // Record position at every frame to map x positions correctly
            pathPoints.append((currentX, currentY))
            uniqueYValues.insert(Int(currentY))
            minY = min(minY, currentY)
            maxY = max(maxY, currentY)
        }

        // Calculate min/max from unique y values
        if let minYInt = uniqueYValues.min(), let maxYInt = uniqueYValues.max() {
            minY = Double(minYInt)
            maxY = Double(maxYInt)
        }

        let pathHeight = Int(maxY - minY) + 1

        // Step 2: Fill entire rectangle with spaces
        var pathLines: [String] = Array(
            repeating: String(repeating: " ", count: width), count: pathHeight)

        // Step 3: Walk the path, mapping screen x positions to dolphin's actual path
        // Dolphin3 starts at dolphinStartX (relative x = 0), so at screen x, dolphin is at relative x = screenX - dolphinStartX
        for screenX in 0..<width {
            // Calculate dolphin's relative x position (where dolphin would be horizontally)
            let dolphinRelativeX = Double(screenX - dolphinStartX)

            // Find the path points that bracket this x position
            // Since path repeats, we need to handle modulo
            let pathCycleLength = pathPoints.last?.x ?? 1.0
            let normalizedX = dolphinRelativeX.truncatingRemainder(dividingBy: pathCycleLength)
            let normalizedXPositive = normalizedX < 0 ? normalizedX + pathCycleLength : normalizedX

            // Find the two path points to interpolate between
            var pathIndex = 0
            for i in 0..<(pathPoints.count - 1) {
                if normalizedXPositive >= pathPoints[i].x
                    && normalizedXPositive <= pathPoints[i + 1].x
                {
                    pathIndex = i
                    break
                }
            }

            let point1 = pathPoints[pathIndex]
            let point2 = pathPoints[min(pathIndex + 1, pathPoints.count - 1)]

            // Interpolate y position based on x position
            let t: Double
            if point2.x != point1.x {
                t = (normalizedXPositive - point1.x) / (point2.x - point1.x)
            } else {
                t = 0.0
            }

            let y = point1.y + (point2.y - point1.y) * t
            let relativeY = Int(y - minY)

            if relativeY >= 0 && relativeY < pathHeight {
                // Mark this position in the path
                let char: Character = "·"
                var line = pathLines[relativeY]
                let index = line.index(line.startIndex, offsetBy: screenX)
                line.replaceSubrange(index...index, with: String(char))
                pathLines[relativeY] = line
            }
        }

        // Cache the result
        cachedPath = pathLines
        cachedWidth = width

        return pathLines
    }
}
