//
//  WhaleEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/16/25.
//

import Foundation

// MARK: - Whale Entity
class WhaleEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 0.5  // Speed matching Perl: $speed = 1
    private var fractionalX: Double = 0.0  // Accumulate fractional movement

    // Spout animation properties
    private let originalShape: [String]
    private var spoutFrame: Int? = nil
    private let spoutDelay = 20
    private let spoutLength = 10
    private let spoutShapes = ["'", "`", "."]

    // Whale shapes (left and right facing) - matching Perl
    // Note: The top line is reserved for the spout.
    private static let whaleShapeRight = [
        "                              ",  // Spout line
        "        .-----:",
        "      .'       `.",
        ",    /       (o) \\",
        "\\`._/          ,__)",
    ]

    private static let whaleShapeLeft = [
        "                              ",  // Spout line
        "    :-----.",
        "  .'       `.",
        " / (o)       \\    ,",
        "(__,          \\_.'/",
    ]

    // Whale color masks (matching Perl: @whale_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'C' = cyan bright, 'B' = blue, 'W' = white
    // Note: Masks include spout area (3 extra lines at top) + whale shape (4 lines)
    private static let whaleMaskRight = [
        "",  // Spout line (no color)
        "        BBBBBBB",  // Whale line 1
        "      BBxxxxxxxBB",  // Whale line 2
        "B    BxxxxxxxBWBxB",  // Whale line 3
        "BBBBBxxxxxxxxxxBBBB",  // Whale line 4
    ]

    private static let whaleMaskLeft = [
        "",  // Spout line (no color)
        "    BBBBBBB",  // Whale line 1
        "  BBxxxxxxxBB",  // Whale line 2
        " BxBWBxxxxxxxB    B",  // Whale line 3
        "BBBBxxxxxxxxxxBBBBB",  // Whale line 4
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? WhaleEntity.whaleShapeRight : WhaleEntity.whaleShapeLeft
        let mask = randomDir > 0 ? WhaleEntity.whaleMaskRight : WhaleEntity.whaleMaskLeft

        self.originalShape = shape
        super.init(name: name, type: .whale, shape: shape, position: position)
        self.direction = randomDir
        self.colorMask = mask
        setupWhale()
    }

    private func setupWhale() {
        dieOffscreen = true
        defaultColor = .white
        autoTransparent = true
        // Perl: callback_args => [ $speed, 0, 0, 1 ]
        callbackArgs = [speed, Double(direction), 0.0, 1.0]
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        handleSpoutAnimation()
    }

    private func handleSpoutAnimation() {
        // Check if it's time to start the spout animation
        if spoutFrame == nil && (frameCount % (spoutDelay + spoutLength)) > spoutDelay {
            spoutFrame = 0
        }

        if var frame = spoutFrame {
            // End of spout animation
            if frame >= spoutLength {
                spoutFrame = nil
                shape = originalShape
            } else {
                // Display spout frame
                let spoutChar = spoutShapes.randomElement() ?? "."
                var newShape = originalShape
                let spoutX = direction > 0 ? 29 : 5

                let spoutY = 0  // Top line of the shape
                if spoutY < newShape.count {
                    var line = newShape[spoutY]
                    let index =
                        line.index(line.startIndex, offsetBy: spoutX, limitedBy: line.endIndex)
                        ?? line.endIndex
                    if index < line.endIndex {
                        line.replaceSubrange(index...index, with: spoutChar)
                        newShape[spoutY] = line
                    }
                }

                shape = newShape
                frame += 1
                spoutFrame = frame
            }
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Whale moves horizontally based on direction and speed
        // Use fractional accumulation to handle sub-pixel movement
        let gridSpeed = speed * 30.0  // 30 FPS
        fractionalX += gridSpeed * Double(direction) * deltaTime

        // Extract integer movement and keep remainder
        let moveX = Int(fractionalX)
        fractionalX -= Double(moveX)

        return Position3D(
            position.x + moveX,
            position.y,
            position.z
        )
    }
}
