//
//  FishEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Fish Entity
class FishEntity: BaseEntity {
    var speed: Double = 1.0
    var direction: Int = 1  // 1 for right, -1 for left
    var bubbleChance: Double = 0.03  // 3% chance per frame to generate bubble

    init(name: String, position: Position3D) {
        super.init(name: name, type: .fish, shape: [""], position: position)
        setupFish()
    }

    private func setupFish() {
        // Set up fish-specific properties
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan
        callbackArgs = [speed, Double(direction), 0.0, 0.0]

        // Set random fish shape and color
        setupRandomFishAppearance()
    }

    private func setupRandomFishAppearance() {
        // Random fish shape from the Perl source
        let fishShapes = [
            // Fish 1 - Right facing
            [
                "       \\",
                "     ...\\..,",
                "\\  /'       \\",
                " >=     (  ' >",
                "/  \\      / /",
                "    `\"'\"'/'",
            ],
            // Fish 2 - Left facing
            [
                "      /",
                "  ,../...",
                " /       '\\  /",
                "< '  )     =<",
                " \\ \\      /  \\",
                "  `'\\'\"'\"'",
            ],
            // Fish 3 - Simple right
            [
                "    \\",
                "\\ /--\\",
                ">=  (o>",
                "/ \\__/",
                "    /",
            ],
            // Fish 4 - Simple left
            [
                "  /",
                " /--\\ /",
                "<o)  =<",
                " \\__/ \\",
                "  \\",
            ],
        ]

        let randomShape = fishShapes.randomElement() ?? fishShapes[0]
        shape = randomShape

        // Random color
        let colors: [ColorCode] = [.cyan, .red, .yellow, .blue, .green, .magenta]
        defaultColor = colors.randomElement() ?? .cyan
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Fish-specific movement logic
        return Position3D(
            position.x + Int(speed * Double(direction) * deltaTime),
            position.y,
            position.z
        )
    }

    func shouldGenerateBubble() -> Bool {
        return Double.random(in: 0...1) < bubbleChance
    }

    func generateBubblePosition() -> Position3D {
        // Bubble appears above the fish
        let bubbleX = direction > 0 ? position.x + size.width : position.x
        let bubbleY = position.y + size.height / 2
        return Position3D(bubbleX, bubbleY, position.z - 1)
    }
}
