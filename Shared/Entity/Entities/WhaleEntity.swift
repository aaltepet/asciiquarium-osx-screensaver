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

    // Whale shapes (left and right facing) - matching Perl
    // Note: Shape includes empty lines at top for spout area (3 lines) + whale body (4 lines)
    // The spout animation is handled separately in Perl, but for now we'll use a static shape.
    // Spout animation can be added later by updating the shape array dynamically.
    private static let whaleShapeRight = [
        "",  // Spout line 1 (empty for now)
        "",  // Spout line 2 (empty for now)
        "",  // Spout line 3 (empty for now)
        "        .-----:",  // Whale line 1
        "      .'       `.",  // Whale line 2
        ",xxxx/       (o) \\",  // Whale line 3
        "\\`._/          ,__)",  // Whale line 4
    ]

    private static let whaleShapeLeft = [
        "",  // Spout line 1 (empty for now)
        "",  // Spout line 2 (empty for now)
        "",  // Spout line 3 (empty for now)
        "    :-----.",  // Whale line 1
        "  .'       `.",  // Whale line 2
        " / (o)       \\    ,",  // Whale line 3
        "(__,          \\_.'/)",  // Whale line 4
    ]

    // Whale color masks (matching Perl: @whale_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'C' = cyan bright, 'B' = blue, 'W' = white
    // Note: Masks include spout area (3 extra lines at top) + whale shape (4 lines)
    private static let whaleMaskRight = [
        "             C C",  // Spout line 1
        "           CCCCCCC",  // Spout line 2
        "           C  C  C",  // Spout line 3
        "        BBBBBBB",  // Whale line 1
        "      BBxxxxxxxBB",  // Whale line 2
        "B    BxxxxxxxBWBxB",  // Whale line 3
        "BBBBBxxxxxxxxxxBBBB",  // Whale line 4
    ]

    private static let whaleMaskLeft = [
        "   C C",  // Spout line 1
        " CCCCCCC",  // Spout line 2
        " C  C  C",  // Spout line 3
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
