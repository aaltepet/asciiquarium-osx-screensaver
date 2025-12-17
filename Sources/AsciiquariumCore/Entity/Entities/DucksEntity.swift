//
//  DucksEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/18/25.
//

import Foundation

// MARK: - Ducks Entity
public class DucksEntity: BaseEntity {
    public var direction: Int = 1  // 1 for right, -1 for left
    public var speed: Double = 0.5  // Speed matching Perl: $speed = 1
    private var fractionalX: Double = 0.0  // Accumulate fractional movement
    private var previousIntegerX: Int = 0  // Track previous integer X position for animation
    private var animationFrameIndex: Int = 0  // Current animation frame index

    // Ducks shapes (left and right facing) - matching Perl
    // Each direction has 3 animation frames
    private static let ducksShapeRightFrames = [
        [
            "      _          _          _  ",
            ",____(')=  ,____(')=  ,____(')<",
            " \\~~= ')    \\~~= ')    \\~~= ') ",
        ],
        [
            "      _          _          _  ",
            ",____(')=  ,____(')<  ,____(')=",
            " \\~~= ')    \\~~= ')    \\~~= ') ",
        ],
        [
            "      _          _          _  ",
            ",____(')<  ,____(')=  ,____(')=",
            " \\~~= ')    \\~~= ')    \\~~= ') ",
        ],
    ]

    private static let ducksShapeLeftFrames = [
        [
            "  _          _          _",
            ">(')____,  =(')____,  =(')____,",
            " (` =~~/    (` =~~/    (` =~~/",
        ],
        [
            "  _          _          _",
            "=(')____,  >(')____,  =(')____,",
            " (` =~~/    (` =~~/    (` =~~/",
        ],
        [
            "  _          _          _",
            "=(')____,  =(')____,  >(')____,",
            " (` =~~/    (` =~~/    (` =~~/",
        ],
    ]

    // Ducks color masks (matching Perl: @duck_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'g' = green, 'w' = white, 'y' = yellow, 'W' = white bright, 'c' = cyan, 'C' = cyan bright
    private static let ducksMaskRight = [
        "      g          g          g  ",  // 30 chars - matches shape line 1
        "wwwwwgcgy  wwwwwgcgy  wwwwwgcgy ",  // 34 chars - matches shape line 2
        " wwwwxWw    wwwwxWw    wwwwxWw ",  // 34 chars - matches shape line 3
    ]

    private static let ducksMaskLeft = [
        "  g          g          g",  // 26 chars - matches shape line 1
        "ygcgwwwww  ygcgwwwww  ygcgwwwww",  // 33 chars - matches shape line 2
        " wWxwwww    wWxwwww    wWxwwww",  // 33 chars - matches shape line 3
    ]

    public init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let frames =
            randomDir > 0 ? DucksEntity.ducksShapeRightFrames : DucksEntity.ducksShapeLeftFrames
        let mask = randomDir > 0 ? DucksEntity.ducksMaskRight : DucksEntity.ducksMaskLeft

        super.init(name: name, type: .ducks, shape: frames[0], position: position)
        self.direction = randomDir
        self.colorMask = mask
        self.previousIntegerX = position.x
        setupDucks()
    }

    private func setupDucks() {
        dieOffscreen = true
        defaultColor = .white
        autoTransparent = true
        // Perl: callback_args => [ $speed, 0, 0, .25 ]
        callbackArgs = [speed, Double(direction), 0.0, 0.25]
    }

    public override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate ducks: only advance frame when integer position changes
        // This ensures animation is tied to actual grid movement, not frame count
        let currentIntegerX = position.x
        if currentIntegerX != previousIntegerX {
            // Position changed by an integer amount - advance animation frame
            let frames =
                direction > 0
                ? DucksEntity.ducksShapeRightFrames : DucksEntity.ducksShapeLeftFrames
            animationFrameIndex = (animationFrameIndex + 1) % frames.count
            shape = frames[animationFrameIndex]
            previousIntegerX = currentIntegerX
        }
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Ducks move horizontally based on direction and speed
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
