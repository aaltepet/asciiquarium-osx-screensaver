//
//  Entity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation
import SwiftUI

/// Legacy AquariumEntity struct for backward compatibility
/// This is now deprecated in favor of the new Entity protocol system
@available(*, deprecated, message: "Use the new Entity protocol system instead")
struct AquariumEntity {
    enum EntityType: CaseIterable {
        case fish
    }

    let type: EntityType
    var position: CGPoint
    let shape: String
    let color: Color
    let speed: Double
    var velocity: CGPoint
    let spawnTime: TimeInterval
    let lifetime: TimeInterval

    init(type: EntityType, position: CGPoint, shape: String, color: Color, speed: Double) {
        self.type = type
        self.position = position
        self.shape = shape
        self.color = color
        self.speed = speed
        self.spawnTime = Date().timeIntervalSince1970
        self.lifetime = Double.random(in: 30...120)  // 30 seconds to 2 minutes

        // Set velocity based on type
        switch type {
        case .fish:
            self.velocity = CGPoint(
                x: CGFloat.random(in: -speed...speed),
                y: CGFloat.random(in: -speed / 2...speed / 2)
            )
        }
    }

    mutating func update(deltaTime: Double, bounds: CGRect) {
        // Update position
        position.x += velocity.x * CGFloat(deltaTime)
        position.y += velocity.y * CGFloat(deltaTime)

        // Handle screen wrapping for fish
        if type == .fish {
            if position.x < 0 {
                position.x = bounds.width
            } else if position.x > bounds.width {
                position.x = 0
            }

            if position.y < 0 {
                position.y = bounds.height
            } else if position.y > bounds.height {
                position.y = 0
            }
        }

        // Add some random movement to fish
        if type == .fish && Double.random(in: 0...1) < 0.1 {
            velocity.x += CGFloat.random(in: -0.5...0.5)
            velocity.y += CGFloat.random(in: -0.2...0.2)

            // Limit velocity
            velocity.x = max(-2.0, min(2.0, velocity.x))
            velocity.y = max(-1.0, min(1.0, velocity.y))
        }
    }

    func isOffScreen(bounds: CGRect) -> Bool {
        switch type {
        case .fish:
            return false  // Fish wrap around screen
        }
    }

    func isExpired(currentTime: TimeInterval) -> Bool {
        return currentTime - spawnTime > lifetime
    }
}
