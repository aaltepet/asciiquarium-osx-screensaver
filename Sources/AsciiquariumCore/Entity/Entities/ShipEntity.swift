//
//  ShipEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/16/25.
//

import Foundation

// MARK: - Ship Entity
public class ShipEntity: BaseEntity {
    public var direction: Int = 1  // 1 for right, -1 for left
    public var speed: Double = 0.75  // Speed matching Perl: $speed = 1

    // Ship shapes (left and right facing) - matching Perl
    private static let shipShapeRight = [
        "     |    |    |",
        "    )_)  )_)  )_)",
        "   )___))___))___)\\",
        "  )____)____)_____)\\\\",
        "_____|____|____|____\\\\\\__",
        "\\                   /",
    ]

    private static let shipShapeLeft = [
        "         |    |    |",
        "        (_(  (_(  (_(",
        "      /(___((___((___(",
        "    //(_____(____(____(",
        "__///____|____|____|_____",
        "    \\                   /",
    ]

    // Ship color masks (matching Perl: @ship_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'y' = yellow, 'w' = white
    private static let shipMaskRight = [
        "     y    y    y",
        "",
        "                  w",
        "                   ww",
        "yyyyyyyyyyyyyyyyyyyywwwyy",
        "yxxxxxxxxxxxxxxxxxxxy",
    ]

    private static let shipMaskLeft = [
        "         y    y    y",
        "",
        "      w",
        "    ww",
        "yywwwyyyyyyyyyyyyyyyyyyyy",
        "    yxxxxxxxxxxxxxxxxxxxy",
    ]

    public init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? ShipEntity.shipShapeRight : ShipEntity.shipShapeLeft
        let mask: [String] = randomDir > 0 ? ShipEntity.shipMaskRight : ShipEntity.shipMaskLeft

        super.init(name: name, type: .ship, shape: shape, position: position)
        self.direction = randomDir
        self.colorMask = mask
        setupShip()
    }

    private func setupShip() {
        dieOffscreen = true
        defaultColor = .white
        autoTransparent = true
        callbackArgs = [speed, Double(direction), 0.0, 0.0]
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Ship moves horizontally based on direction and speed
        let gridSpeed = speed * 30.0  // 30 FPS
        let moveX = Int(gridSpeed * Double(direction) * deltaTime)

        return Position3D(
            position.x + moveX,
            position.y,
            position.z
        )
    }
}
