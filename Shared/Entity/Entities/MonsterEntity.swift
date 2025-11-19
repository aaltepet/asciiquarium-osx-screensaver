//
//  MonsterEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/16/25.
//

import Foundation

// MARK: - Monster Entity
class MonsterEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 1  // Speed matching Perl: $speed = 2
    private var fractionalX: Double = 0.0  // Accumulate fractional movement
    private var previousIntegerX: Int = 0  // Track previous integer X position for animation
    private var animationFrameIndex: Int = 0  // Current animation frame index

    // Monster shapes (left and right facing) - matching Perl
    // Note: In Perl, $monster_image[0] is right-facing (4 frames), $monster_image[1] is left-facing (4 frames)
    // Each direction has 4 animation frames that cycle
    private static let monsterShapeRightFrames = [
        [
            "                                                          ____",
            "            __                                          /   o  \\",
            "          /    \\        _                     _       /     ____ >",
            "  _      |  __  |     /   \\        _        /   \\    |     |",
            " | \\     |  ||  |    |     |     /   \\     |     |   |     |",
        ],
        [
            "                                                          ____",
            "                                             __         /   o  \\",
            "             _                     _       /    \\     /     ____ >",
            "   _       /   \\        _        /   \\    |  __  |   |     |",
            "  | \\     |     |     /   \\     |     |   |  ||  |   |     |",
        ],
        [
            "                                                          ____",
            "                                  __                     /   o  \\",
            "_                     _       /    \\        _          /     ____ >",
            "| \\        _        /   \\    |  __  |     /   \\       |     |",
            " \\ \\     /   \\     |     |   |  ||  |    |     |      |     |",
        ],
        [
            "                                                          ____",
            "                       __                               /   o  \\",
            "  _       /    \\        _                     _       /     ____ >",
            " | \\     |  __  |     /   \\        _        /   \\    |     |",
            "  \\ \\    |  ||  |    |     |     /   \\     |     |   |     |",
        ],
    ]

    // Monster color masks (matching Perl: @monster_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'W' = white (for the eye)
    // Note: Perl uses a very simple mask - just 'W' for the eye position
    // We'll use a full mask based on the shape for proper collision detection
    private static let monsterMaskRight = [
        "                                                          gggg",
        "                                             gg         gxxxoxxg",
        "            g                    g         gxxxxg     gxxxxxggggxw",
        "  g       gxxxg       g        gxxxg      gxxggxxg   gxxxxxg",
        " gxg     gxxxxxg    gxxxg     gxxxxxg     gxxggxxg   gxxxxxg",
    ]

    private static let monsterShapeLeftFrames = [
        [
            "    ____",
            "  /  o   \\                                          __",
            "< ____     \\        _                     _       /    \\",
            "      |     |     /   \\        _        /   \\    |  __  |",
            "      |     |    |     |     /   \\     |     |   |  ||  |",
        ],
        [
            "    ____",
            "  /  o   \\         __",
            "< ____     \\     /    \\        _                     _",
            "      |     |    |  __  |     /   \\        _        /   \\",
            "      |     |    |  ||  |    |     |     /   \\     |     |",
        ],
        [
            "    ____",
            "  /  o   \\                     __",
            "< ____     \\        _       /    \\        _          _",
            "      |     |     /   \\    |  __  |     /   \\       | \\",
            "      |     |    |     |   |  ||  |    |     |      \\ \\",
        ],
        [
            "    ____",
            "  /  o   \\                               __",
            "< ____     \\        _                     _       /    \\",
            "      |     |     /   \\        _        /   \\    |  __  |",
            "      |     |    |     |     /   \\     |     |   |  ||  |",
        ],
    ]

    private static let monsterMaskLeft = [
        "    gggg",
        "  gxxgxxxg                                          gg",
        "gxggggxxxxxg        g                     g       gxxxxg",
        "      gxxxxxg     gxxxg        g        gxxxg    gxxggxxg",
        "      gxxxxxg    gxxxxxg     gxxxg     gxxxxxg   gxxggxxg",
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let frames =
            randomDir > 0
            ? MonsterEntity.monsterShapeRightFrames : MonsterEntity.monsterShapeLeftFrames
        let mask = randomDir > 0 ? MonsterEntity.monsterMaskRight : MonsterEntity.monsterMaskLeft

        // Start with first frame
        super.init(name: name, type: .monster, shape: frames[0], position: position)
        self.direction = randomDir
        self.colorMask = mask
        self.previousIntegerX = position.x
        setupMonster()
    }

    private func setupMonster() {
        dieOffscreen = true
        defaultColor = .green
        autoTransparent = true
        // Perl: callback_args => [ $speed, 0, 0, 0.25 ]
        callbackArgs = [speed, Double(direction), 0.0, 0.25]
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate monster: only advance frame when integer position changes
        // This ensures animation is tied to actual grid movement, not frame count
        let currentIntegerX = position.x
        if currentIntegerX != previousIntegerX {
            // Position changed by an integer amount - advance animation frame
            let frames =
                direction > 0
                ? MonsterEntity.monsterShapeRightFrames : MonsterEntity.monsterShapeLeftFrames
            animationFrameIndex = (animationFrameIndex + 1) % frames.count
            //shape = frames[animationFrameIndex]
            shape = frames[0]
            previousIntegerX = currentIntegerX
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Monster moves horizontally based on direction and speed
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
