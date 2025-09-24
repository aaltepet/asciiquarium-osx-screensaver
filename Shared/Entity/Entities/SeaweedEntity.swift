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
    private let seaweedHeight: Int

    init(name: String, position: Position3D) {
        let height = Int.random(in: 3...6)
        self.seaweedHeight = height
        let seaweedShape = SeaweedEntity.createSeaweedShape(height: height)
        super.init(name: name, type: .seaweed, shape: seaweedShape, position: position)
        setupSeaweed()
    }

    private func setupSeaweed() {
        defaultColor = .green
        dieTime = Date().timeIntervalSince1970 + Double.random(in: 480...720)  // 8-12 minutes
        callbackArgs = [0.0, 0.0, 0.0, 0.25]  // Sway animation
        // Seaweed should not treat spaces as transparent (solid glyphs only)
        transparentChar = nil
    }

    private static func createSeaweedShape(height: Int) -> [String] {
        var lines: [String] = []
        lines.reserveCapacity(height)
        let inverted = Bool.random()
        for i in 0..<height {
            let even = (i % 2 == 0)
            let ch: String
            if inverted {
                ch = even ? ")" : "("
            } else {
                ch = even ? "(" : ")"
            }
            lines.append(ch)
        }
        return lines
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
        shape = SeaweedEntity.createSeaweedShape(height: seaweedHeight)
        // Maintain non-transparent behavior
        transparentChar = nil
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Seaweed sways but doesn't move position
        return nil
    }
}
