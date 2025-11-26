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
    private var spoutCycle = 0
    private let spoutDelay = 20  // frames to wait
    private let spoutLength = 10  // frames spout is active
    private var spoutFrames: [[String]] = []

    // Whale shapes (left and right facing) - matching Perl
    // Note: The top lines are reserved for the spout and padded to avoid crashes.
    private static let whaleShapeRight = [
        "                    ",  // Spout line 1
        "                    ",  // Spout line 2
        "                    ",  // Spout line 3
        "        .-----:     ",
        "      .'       `.   ",
        ",    /       (o) \\ ",
        "\\`._/          ,__)",
    ]

    private static let whaleShapeLeft = [
        "                    ",  // Spout line 1
        "                    ",  // Spout line 2
        "                    ",  // Spout line 3
        "    :-----          ",
        "  .'       `.       ",
        " / (o)       \\    ,",
        "(__,          \\_.'/",
    ]

    // Whale color masks (matching Perl: @whale_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'C' = cyan bright, 'B' = blue, 'W' = white
    // Note: Masks include spout area (3 extra lines at top) + whale shape (4 lines)
    private static let whaleMaskRight = [
        "             C C   ",
        "           CCCCCCC ",
        "           C  C  C ",
        "        BBBBBBB    ",
        "      BBxxxxxxxBB  ",
        "B    BxxxxxxxBWBxB ",
        "BBBBBxxxxxxxxxxBBBB",
    ]

    private static let whaleMaskLeft = [
        "   C C             ",
        " CCCCCCC           ",
        " C  C  C           ",
        "    BBBBBBB        ",
        "  BBxxxxxxxBB      ",
        " BxBWBxxxxxxxB    B",
        "BBBBxxxxxxxxxxBBBBB",
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? WhaleEntity.whaleShapeRight : WhaleEntity.whaleShapeLeft
        let mask = randomDir > 0 ? WhaleEntity.whaleMaskRight : WhaleEntity.whaleMaskLeft

        super.init(name: name, type: .whale, shape: shape, position: position)
        self.direction = randomDir
        self.colorMask = mask
        setupSpoutShapes()
        setupWhale()
    }

    private func setupSpoutShapes() {
        spoutFrames = [
            [
                "       ",
                "       ",
                "   :   ",
            ],
            [
                "       ",
                "   :   ",
                "   :   ",
            ],
            [
                "  . .  ",
                "  -:-  ",
                "   :   ",
            ],
            [
                "  . .  ",
                " .-:-. ",
                "   :   ",
            ],
            [
                "  . .  ",
                " .-:-. ",
                "'  :  '",
            ],
            [
                "       ",
                " .- -. ",
                ";  :  ;",
            ],
            [
                "       ",
                "       ",
                ";     ;",
            ],
        ]
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
        spoutCycle = (spoutCycle + 1) % (spoutDelay + spoutLength)

        if spoutCycle > spoutDelay {
            let frameIndex = spoutCycle - spoutDelay - 1
            let spoutX = direction > 0 ? 11 : 1

            if frameIndex < spoutFrames.count {
                let spoutShape = spoutFrames[frameIndex]
                var newShape =
                    direction > 0 ? WhaleEntity.whaleShapeRight : WhaleEntity.whaleShapeLeft

                for (i, spoutLine) in spoutShape.enumerated() {
                    if i < newShape.count {
                        var line = newShape[i]
                        let start = line.index(line.startIndex, offsetBy: spoutX)
                        let end =
                            line.index(start, offsetBy: spoutLine.count, limitedBy: line.endIndex)
                            ?? line.endIndex
                        let range = start..<end
                        if range.upperBound <= line.endIndex {
                            line.replaceSubrange(range, with: spoutLine)
                            newShape[i] = line
                        }
                    }
                }
                self.shape = newShape
            }
        } else {
            // Restore original shape when not spouting
            self.shape = direction > 0 ? WhaleEntity.whaleShapeRight : WhaleEntity.whaleShapeLeft
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
