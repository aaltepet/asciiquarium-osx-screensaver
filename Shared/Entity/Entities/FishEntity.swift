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
        // Set up fish-specific properties
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan

        // Randomize initial direction and appearance
        direction = Bool.random() ? 1 : -1
        setupRandomFishAppearance()

        // Sync movement args with randomized direction
        callbackArgs = [speed, Double(direction), 0.0, 0.0]
    }

    private func setupRandomFishAppearance() {
        // Right-facing shapes
        let rightFacingShapes: [[String]] = [
            [
                "       \\",
                "     ...\\..,",
                "\\  /'       \\",
                " >=     (  ' >",
                "/  \\      / /",
                "    `\"'\"'/'",
            ],
            [
                "    \\",
                "\\ /--\\",
                ">=  (o>",
                "/ \\__/",
                "    /",
            ],
        ]

        // Left-facing shapes
        let leftFacingShapes: [[String]] = [
            [
                "      /",
                "  ,../...",
                " /       '\\  /",
                "< '  )     =<",
                " \\ \\      /  \\",
                "  `'\\'\"'\"'",
            ],
            [
                "  /",
                " /--\\ /",
                "<o)  =<",
                " \\__/ \\",
                "  \\",
            ],
        ]

        // Pick from the set matching our direction
        let pool = direction > 0 ? rightFacingShapes : leftFacingShapes
        shape = pool.randomElement() ?? (direction > 0 ? rightFacingShapes[0] : leftFacingShapes[0])

        // Random color
        let colors: [ColorCode] = [.cyan, .red, .yellow, .blue, .green, .magenta]
        defaultColor = colors.randomElement() ?? .cyan
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Fish-specific movement logic - move 1 grid cell per second
        let gridSpeed = speed * 30.0  // 30 FPS * 1 cell/second = 1 cell per frame
        let moveX = Int(gridSpeed * Double(direction) * deltaTime)

        return Position3D(
            position.x + moveX,
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
