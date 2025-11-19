//
//  SwanEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/16/25.
//

import Foundation

// MARK: - Swan Entity
class SwanEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 0.5  // Speed matching Perl: $speed = 1
    private var fractionalX: Double = 0.0  // Accumulate fractional movement

    // Swan shapes (left and right facing) - matching Perl
    private static let swanShapeRight = [
        "       ___",
        ",_    / _,\\",
        "| \\   \\( \\|",
        "|  \\_  \\\\",
        "(_   \\_) \\",
        "(\\_   `   \\",
        " \\   -=~  /",
    ]

    private static let swanShapeLeft = [
        " ___",
        "/,_ \\    _,",
        "|/ )/   / |",
        "  //  _/  |",
        " / ( /   _)",
        "/   `   _/)",
        "\\  ~=-   /",
    ]

    // Swan color masks (matching Perl: @swan_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'g' = green, 'y' = yellow
    private static let swanMaskRight = [
        "       xxx ",
        "xx    xxxgx",
        "xxx   xxxyy",
        "xxxxx  xx  ",
        "xxxxxx xxx ",
        "xxxxxxxxxxx",
        " xxxxxxxxxx",
    ]

    private static let swanMaskLeft = [
        " xxx",
        "xgxxx    xx",
        "yyxxx   xxx",
        "  xx  xxxxx",
        " xxx xxxxxx",
        "xxxxxxxxxxx",
        "xxxxxxxxxx",
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? SwanEntity.swanShapeRight : SwanEntity.swanShapeLeft
        let mask = randomDir > 0 ? SwanEntity.swanMaskRight : SwanEntity.swanMaskLeft

        super.init(name: name, type: .swan, shape: shape, position: position)
        self.direction = randomDir
        self.colorMask = mask
        setupSwan()
    }

    private func setupSwan() {
        dieOffscreen = true
        defaultColor = .white
        autoTransparent = true
        // Perl: callback_args => [ $speed, 0, 0, .25 ]
        callbackArgs = [speed, Double(direction), 0.0, 0.25]
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Swan moves horizontally based on direction and speed
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
