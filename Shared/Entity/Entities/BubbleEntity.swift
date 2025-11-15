//
//  BubbleEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Bubble Entity
class BubbleEntity: BaseEntity {
    private var animationFrame: Int = 0
    private let animationFrames = [".", "o", "O", "O", "O"]

    init(name: String, position: Position3D) {
        super.init(name: name, type: .bubble, shape: ["."], position: position)
        setupBubble()
    }

    private func setupBubble() {
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan
        callbackArgs = [0.0, 0.0, -1.0, 0.1]  // Move upward
        transparentChar = " "

        // Set up collision handler: bubble dies when it collides with waterline
        collisionHandler = { [weak self] bubble, collidingEntities in
            // Check if any colliding entity is a waterline
            for entity in collidingEntities {
                if entity.type == .waterline {
                    // Bubble pops when it reaches the water surface
                    self?.kill()
                    return  // Only need to kill once
                }
            }
        }
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate bubble growth
        if frameCount % 10 == 0 {  // Change frame every 10 updates
            animationFrame = (animationFrame + 1) % animationFrames.count
            shape = [animationFrames[animationFrame]]
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Bubble rises upward
        return Position3D(
            position.x,
            position.y - 1,
            position.z
        )
    }

    func checkWaterlineCollision(with entities: [Entity]) -> Bool {
        for entity in entities {
            if entity.type == .waterline {
                let myBounds = getBounds()
                let otherBounds = entity.getBounds()

                if myBounds.overlaps(with: otherBounds) {
                    return true
                }
            }
        }
        return false
    }
}
