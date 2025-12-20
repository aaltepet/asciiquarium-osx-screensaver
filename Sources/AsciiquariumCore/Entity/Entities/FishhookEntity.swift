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

    public init(name: String, position: Position3D) {
        let hookShape = [
            "       o",
            "      ||",
            "      ||",
            "/ \\   ||",
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

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let args = callbackArgs, args.count >= 3 else { return nil }

        let speed = args[0] as? Double ?? 0.0
        let dy = (group?.state ?? .descending) == .descending ? 1.0 : -1.0

        // 30 FPS * 1 cell/sec = 1 cell per frame
        let gridSpeed = speed * 30.0
        let movementThisFrame = gridSpeed * dy * deltaTime

        let newY = Double(position.y) + movementThisFrame

        if (group?.state ?? .descending) == .descending {
            // Stop at 75% of grid height
            let maxHeight = Double(gridHeight) * 0.75
            if newY + Double(size.height) > maxHeight {
                return Position3D(position.x, Int(maxHeight - Double(size.height)), position.z)
            }
        }

        return Position3D(position.x, Int(newY), position.z)
    }
}
