//
//  FishhookEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class FishhookEntity: BaseEntity {
    public var group: FishingGroup?
    public var gridHeight: Int = 24  // Default grid height
    private var timeAtMaxDepth: TimeInterval = 0
    private let maxTimeAtBottom: TimeInterval = 30.0  // Retract after 30 seconds at bottom

    public init(name: String, position: Position3D) {
        let hookShape = [
            "      o",
            "     ||",
            "     ||",
            "/ \\  ||",
            "  \\__//",
            "  `--' ",
        ]
        super.init(name: name, type: .fishhook, shape: hookShape, position: position)
        setupFishhook()
    }

    private func setupFishhook() {
        dieOffscreen = true
        defaultColor = .green
        transparentChar = " "
        // Speed: 1.0 cell/tick -> 30 cells/sec
        // callbackArgs: [speed, dx, dy, dz]
        callbackArgs = [1.0, 0.0, 1.0, 0.0]
    }

    public override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Handle timed retraction if we've reached max depth and aren't already retracting
        if let group = group, group.state == .descending {
            let maxHeight = Double(gridHeight) * 0.75
            // Check if we are at or near max depth (within 1 cell)
            if Double(position.y) + Double(size.height) >= maxHeight - 1.0 {
                timeAtMaxDepth += deltaTime
                if timeAtMaxDepth >= maxTimeAtBottom {
                    group.retract()
                }
            }
        }
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let args = callbackArgs, args.count >= 3, let group = group else { return nil }

        let speed = args[0] as? Double ?? 0.0
        let dy = group.state == .descending ? 1.0 : -1.0

        // 30 FPS * 1 cell/sec = 1 cell per frame
        let gridSpeed = speed * 30.0
        let movementThisFrame = gridSpeed * dy * deltaTime

        // Update the shared floating-point Y in the group
        group.y += movementThisFrame

        if group.state == .descending {
            // Stop at 75% of grid height
            let maxHeight = Double(gridHeight) * 0.75
            if group.y + Double(size.height) > maxHeight {
                group.y = maxHeight - Double(size.height)
            }
        }

        return Position3D(position.x, Int(floor(group.y)), position.z)
    }
}
