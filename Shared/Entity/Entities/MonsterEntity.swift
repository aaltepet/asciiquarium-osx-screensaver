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

    // Monster color masks (matching Perl: @monster_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'W' = white (for the eye)
    // Note: Perl uses a very simple mask - just 'W' for the eye position
    // We'll use a full mask based on the shape for proper collision detection
    private static let monsterMaskRight = [
        "                                                          ____",
        "                                             gg         /   o  \\",
        "             _                     _       gxxxxg     /     ____ >",
        "   _       /xxx\\        _        /xxx\\    |xx__xx|   |xxxxx|",
        "  |x\\     |xxxxx|     /xxx\\     |xxxxx|   |xx||xx|   |xxxxx|",
    ]

    private static let monsterMaskLeft = [
        "    ____",
        "  /  o   \\                                          __",
        "< ____     \\        _                     _       /    \\",
        "      |     |     /   \\        _        /   \\    |  __  |",
        "      |     |    |     |     /   \\     |     |   |  ||  |",
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

        // Animate monster (cycle through 4 frames)
        // Slow down animation: change frame every 3 frames (10 FPS animation at 30 FPS)
        // This matches the movement speed better and prevents flickering
        let frames =
            direction > 0
            ? MonsterEntity.monsterShapeRightFrames : MonsterEntity.monsterShapeLeftFrames
        let animationFrame = (frameCount / 3) % frames.count
        shape = frames[animationFrame]
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
