//
//  DolphinEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/19/25.
//

import Foundation

// MARK: - Dolphin Entity
class DolphinEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 1.0  // Speed matching Perl: $speed = 1
    private var fractionalX: Double = 0.0  // Accumulate fractional movement
    private var fractionalY: Double = 0.0  // Accumulate fractional Y movement
    private var pathIndex: Int = 0  // Current index in the path
    private var pathOffset: Int = 0  // Delay before starting path (in frames)
    private var path: [[Double]] = []  // Path to follow: array of [speed, dx, dy, dz]

    // Dolphin shapes (left and right facing) - matching Perl
    // Each direction has 2 animation frames (up and down positions)
    private static let dolphinShapeRightFrames = [
        [
            "*       ,",
            "      __)\\_",
            "(\\_.-'    a`-.",
            "(/~~````(/~^^`",
        ],
        [
            "*       ,",
            "(\\__  __)\\_",
            "(/~.''    a`-.",
            "    ````\\)~^^`",
        ],
    ]

    // Dolphin color masks (matching Perl: @dolphin_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'W' = white (for the eye)
    // Each frame needs its own mask to match the shape
    private static let dolphinMaskRightFrames = [
        [
            "*       x",
            "      xxxxx",
            "xxxxxxxxxxWxxx",
            "xxxxxxxxxxxxxx",
        ],
        [
            "*       x",
            "xxxx  xxxxx",
            "xxxxxxxxxxWxxx",
            "    xxxxxxxxxx",
        ],
    ]

    private static let dolphinShapeLeftFrames = [
        [
            "*    ,",
            "   _/(__",
            ".-'a    `-._/)",
            "'^^~\\)''''~~\\)",
        ],
        [
            "*    ,",
            "   _/(__  __/)",
            ".-'a    ``.~\\)",
            "'^^~(/''''",
        ],
    ]

    private static let dolphinMaskLeftFrames = [
        [
            "*    x        ",
            "   xxxxx      ",
            "xxxWxxxxxxxxxx",
            "xxxxxxxxxxxxxx",
        ],
        [
            "*    x        ",
            "   xxxxx  xxxx",
            "xxxWxxxxxxxxxx",
            "xxxxxxxxxx",
        ],
    ]

    init(name: String, position: Position3D, direction: Int, pathOffset: Int, path: [[Double]]) {
        // Use provided direction
        let frames =
            direction > 0
            ? DolphinEntity.dolphinShapeRightFrames : DolphinEntity.dolphinShapeLeftFrames
        let maskFrames =
            direction > 0
            ? DolphinEntity.dolphinMaskRightFrames : DolphinEntity.dolphinMaskLeftFrames

        super.init(name: name, type: .dolphins, shape: frames[0], position: position)
        self.direction = direction
        self.colorMask = maskFrames[0]  // Start with first frame's mask
        self.pathOffset = pathOffset
        self.path = path
        self.dieOffscreen = true
        setupDolphin()
    }

    private func setupDolphin() {
        defaultColor = .blue
        autoTransparent = true
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Determine current path step
        // The pathOffset is the step index to start at, so we add it to frameCount
        let stepIndex = (frameCount + pathOffset) % path.count

        // Update animation frame based on vertical movement direction
        let frames =
            direction > 0
            ? DolphinEntity.dolphinShapeRightFrames : DolphinEntity.dolphinShapeLeftFrames
        let maskFrames =
            direction > 0
            ? DolphinEntity.dolphinMaskRightFrames : DolphinEntity.dolphinMaskLeftFrames
        if stepIndex < path.count {
            let step = path[stepIndex]
            if step.count >= 3 {
                let dy = step[2]  // Vertical direction
                // Use frame 0 for up movement (dy < 0), frame 1 for down/glide (dy >= 0)
                let frameIndex = dy < 0 ? 0 : 1
                shape = frames[frameIndex]
                colorMask = maskFrames[frameIndex]  // Update mask to match current frame
            }
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Wait for path offset before starting to follow path
        if frameCount < pathOffset {
            // Still move horizontally during offset period
            let gridSpeed = speed * 30.0
            fractionalX += gridSpeed * Double(direction) * deltaTime
            let moveX = Int(fractionalX)
            fractionalX -= Double(moveX)
            return Position3D(position.x + moveX, position.y, position.z)
        }

        // Follow the path, using an effective frame count that starts from 0 after the delay
        let effectiveFrameCount = frameCount - pathOffset
        let stepIndex = effectiveFrameCount % path.count

        guard stepIndex < path.count else {
            return nil
        }

        let step = path[stepIndex]
        guard step.count >= 4 else {
            return nil
        }

        let stepSpeed = step[0]
        let dx = step[1]
        let dy = step[2]
        // dz is in step[3] but not used for movement

        // Apply movement with fractional accumulation
        let gridSpeed = stepSpeed * 30.0  // 30 FPS
        fractionalX += gridSpeed * dx * deltaTime
        fractionalY += gridSpeed * dy * deltaTime

        let moveX = Int(fractionalX)
        let moveY = Int(fractionalY)
        fractionalX -= Double(moveX)
        fractionalY -= Double(moveY)

        return Position3D(
            position.x + moveX,
            position.y + moveY,
            position.z
        )
    }
}
