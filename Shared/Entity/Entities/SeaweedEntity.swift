//
//  SeaweedEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Seaweed Entity
class SeaweedEntity: BaseEntity {
    var swayDirection: Int = 1
    private var swayFrame: Int = 0

    init(name: String, position: Position3D) {
        let height = Int.random(in: 3...6)
        let seaweedShape = createSeaweedShape(height: height)
        super.init(name: name, type: .seaweed, shape: seaweedShape, position: position)
        setupSeaweed()
    }

    private func setupSeaweed() {
        defaultColor = .green
        dieTime = Date().timeIntervalSince1970 + Double.random(in: 480...720)  // 8-12 minutes
        callbackArgs = [0.0, 0.0, 0.0, 0.25]  // Sway animation
    }

    private func createSeaweedShape(height: Int) -> [String] {
        var leftSide = ""
        var rightSide = ""

        for i in 1...height {
            let isLeftSide = i % 2 == 1
            if isLeftSide {
                leftSide += "(\n"
                rightSide += " )\n"
            } else {
                leftSide += " )\n"
                rightSide += "(\n"
            }
        }

        return [leftSide, rightSide]
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate seaweed swaying
        if frameCount % 20 == 0 {  // Change sway every 20 frames
            swayFrame += 1
            updateSwayAnimation()
        }
    }

    private func updateSwayAnimation() {
        // Simple swaying animation by alternating the seaweed shape
        if swayFrame % 2 == 0 {
            // Sway left
            shape = shape.map { line in
                line.replacingOccurrences(of: "(", with: "(")
                    .replacingOccurrences(of: ")", with: ")")
            }
        } else {
            // Sway right
            shape = shape.map { line in
                line.replacingOccurrences(of: "(", with: ")")
                    .replacingOccurrences(of: ")", with: "(")
            }
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Seaweed sways but doesn't move position
        return nil
    }
}
