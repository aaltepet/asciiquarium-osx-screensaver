//
//  SeaweedEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Seaweed Entity
public class SeaweedEntity: BaseEntity {
    public var swayDirection: Int = 1
    private var swayFrame: Int = 0
    private let seaweedHeight: Int
    private var animSpeed: Double = 0.25  // Store for timing calculations
    private var lastSwayFrame: Int = 0

    public init(name: String, position: Position3D) {
        let height = Int.random(in: 3...6)
        self.seaweedHeight = height
        let seaweedShape = SeaweedEntity.createSeaweedShape(height: height)
        super.init(name: name, type: .seaweed, shape: seaweedShape, position: position)
        setupSeaweed()
    }

    private func setupSeaweed() {
        defaultColor = .green
        dieTime = Date().timeIntervalSince1970 + Double.random(in: 480...720)  // 8-12 minutes
        // Random animation speed matching Perl: rand(.05) + .25 (0.25 to 0.30)
        animSpeed = Double.random(in: 0.25...0.30)
        callbackArgs = [0.0, 0.0, 0.0, animSpeed]  // Sway animation with random speed
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

    public override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate seaweed swaying with variable timing based on animSpeed
        // Higher animSpeed (0.30) = faster = more frequent updates (shorter interval)
        // Lower animSpeed (0.25) = slower = less frequent updates (longer interval)
        // Convert animSpeed to frame interval: base interval / animSpeed
        // Base of 5 frames gives: 5/0.30 = ~17 frames, 5/0.25 = 20 frames
        let baseInterval: Double = 5.0
        let swayInterval = Int(baseInterval / animSpeed)

        // Update sway animation when frame count matches the calculated interval
        if frameCount - lastSwayFrame >= swayInterval {
            lastSwayFrame = frameCount
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

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Seaweed sways but doesn't move position
        return nil
    }
}
