//
//  MonsterEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/16/25.
//

import Foundation

// MARK: - Monster Entity
public class MonsterEntity: BaseEntity {
    public var direction: Int = 1  // 1 for right, -1 for left
    public var speed: Double = 0.75  // Speed matching Perl: $speed = 2
    private var fractionalX: Double = 0.0  // Accumulate fractional movement
    private var previousIntegerX: Int = 0  // Track previous integer X position for animation
    private var animationFrameIndex: Int = 0  // Current animation frame index
    private var positionChangeCount: Int = 0  // Count position changes, advance animation every 3

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
            "                                  __                    /   o  \\",
            " _                      _       /    \\        _       /     ____ >",
            "| \\          _        /   \\    |  __  |     /   \\    |     |",
            " \\ \\       /   \\     |     |   |  ||  |    |     |   |     |",
        ],
        [
            "                                                          ____",
            "                       __                               /   o  \\",
            "  _          _       /    \\        _                  /     ____ >",
            " | \\       /   \\    |  __  |     /   \\        _      |     |",
            "  \\ \\     |     |   |  ||  |    |     |     /   \\    |     |",
        ],
    ]
    // Monster color masks (matching Perl: @monster_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'g' = green (body), 'W' = white (eye), 'o' = eye
    // Each frame needs its own mask to match the shape
    private static let monsterMaskRightFrames = [
        [
            "                                                          gggg",
            "            gg                                          gxxxWxxg",
            "          gxxxxg        g                     g       gxxxxxggggxg",
            "  g      gxxggxxg     gxxxg        g        gxxxg    gxxxxxg",
            " gxg     gxxggxxg    gxxxxxg     gxxxg     gxxxxxg   gxxxxxg",
        ],
        [
            "                                                          gggg",
            "                                             gg         gxxxWxxg",
            "             g                     g       gxxxxg     gxxxxxggggxg",
            "   g       gxxxg        g        gxxxg    gxxggxxg   gxxxxxg",
            "  gxg     gxxxxxg     gxxxg     gxxxxxg   gxxggxxg   gxxxxxg",
        ],
        [
            "                                                          gggg",
            "                                  gg                    gxxxWxxg",
            " g                      g       gxxxxg        g       gxxxxxggggxg",
            "gxg          g        gxxxg    gxxggxxg     gxxxg    gxxxxxg",
            " gxg       gxxxg     gxxxxxg   gxxggxxg    gxxxxxg   gxxxxxg",
        ],
        [
            "                                                          gggg",
            "                       gg                               gxxxWxxg",
            "  g          g       gxxxxg        g                  gxxxxxggggxg",
            " gxg       gxxxg    gxxggxxg     gxxxg        g      gxxxxxg",
            "  gxg     gxxxxxg   gxxggxxg    gxxxxxg     gxxxg    gxxxxxg",
        ],
    ]

    private static let monsterShapeLeftFrames = [
        [
            "    ____",
            "  /  o   \\                                          __",
            "< ____     \\       _                     _        /    \\",
            "      |     |    /   \\        _        /   \\     |  __  |      _",
            "      |     |   |     |     /   \\     |     |    |  ||  |     / |",
        ],
        [
            "    ____",
            "  /  o   \\         __",
            "< ____     \\     /    \\       _                     _",
            "      |     |   |  __  |    /   \\        _        /   \\       _",
            "      |     |   |  ||  |   |     |     /   \\     |     |     / |",
        ],
        [
            "    ____",
            "  /  o   \\                    __",
            "< ____     \\       _        /    \\       _                      _",
            "      |     |    /   \\     |  __  |    /   \\        _          / |",
            "      |     |   |     |    |  ||  |   |     |     /   \\       / /",
        ],
        [
            "    ____",
            "  /  o   \\                               __",
            "< ____     \\                  _        /    \\       _          _",
            "      |     |      _        /   \\     |  __  |    /   \\       / |",
            "      |     |    /   \\     |     |    |  ||  |   |     |     / /",
        ],
    ]

    private static let monsterMaskLeftFrames = [
        [
            "    gggg",
            "  gxxWxxxg                                          gg",
            "gxggggxxxxxg       g                     g        gxxxxg",
            "      gxxxxxg    gxxxg        g        gxxxg     gxxggxxg      g",
            "      gxxxxxg   gxxxxxg     gxxxg     gxxxxxg    gxxggxxg     gxg",
        ],
        [
            "    gggg",
            "  gxxWxxxg         gg",
            "gxggggxxxxxg     gxxxxg       g                     g",
            "      gxxxxxg   gxxggxxg    gxxxg        g        gxxxg       g",
            "      gxxxxxg   gxxggxxg   gxxxxxg     gxxxg     gxxxxxg     gxg",
        ],
        [
            "    gggg",
            "  gxxWxxxg                    gg",
            "gxggggxxxxxg       g        gxxxxg       g                      g",
            "      gxxxxxg    gxxxg     gxxggxxg    gxxxg        g          gxg",
            "      gxxxxxg   gxxxxxg    gxxggxxg   gxxxxxg     gxxxg       gxg",
        ],
        [
            "    gggg",
            "  gxxWxxxg                               gg",
            "gxggggxxxxxg                  g        gxxxxg       g          g",
            "      gxxxxxg      g        gxxxg     gxxggxxg    gxxxg       gxg",
            "      gxxxxxg    gxxxg     gxxxxxg    gxxggxxg   gxxxxxg     gxg",
        ],
    ]

    public init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let frames =
            randomDir > 0
            ? MonsterEntity.monsterShapeRightFrames : MonsterEntity.monsterShapeLeftFrames
        let maskFrames =
            randomDir > 0
            ? MonsterEntity.monsterMaskRightFrames : MonsterEntity.monsterMaskLeftFrames

        // Start with first frame
        super.init(name: name, type: .monster, shape: frames[0], position: position)
        self.direction = randomDir
        self.colorMask = maskFrames[0]  // Start with first frame's mask
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

    public override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate monster: advance frame every 6 integer position changes
        // This ensures animation is tied to actual grid movement but at a slower rate
        let currentIntegerX = position.x
        if currentIntegerX != previousIntegerX {
            // Position changed by an integer amount
            positionChangeCount += 1
            previousIntegerX = currentIntegerX

            // Advance animation frame every 3 position changes
            if positionChangeCount >= 6 {
                positionChangeCount = 0
                let frames =
                    direction > 0
                    ? MonsterEntity.monsterShapeRightFrames : MonsterEntity.monsterShapeLeftFrames
                let maskFrames =
                    direction > 0
                    ? MonsterEntity.monsterMaskRightFrames : MonsterEntity.monsterMaskLeftFrames
                animationFrameIndex = (animationFrameIndex + 1) % frames.count
                shape = frames[animationFrameIndex]
                colorMask = maskFrames[animationFrameIndex]  // Update mask to match current frame
            }
        }
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
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
