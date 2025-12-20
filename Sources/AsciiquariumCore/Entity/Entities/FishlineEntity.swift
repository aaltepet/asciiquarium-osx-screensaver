//
//  FishlineEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class FishlineEntity: BaseEntity {
    public var group: FishingGroup?
    public var gridHeight: Int = 24

    public init(name: String, position: Position3D) {
        // A long vertical string of pipes to ensure it reaches the top
        // Perl uses 50 lines. Let's use 100 to be safe for higher resolutions.
        let lineShape = Array(repeating: "|", count: 100)
        super.init(name: name, type: .fishline, shape: lineShape, position: position)
        setupFishline()
    }

    private func setupFishline() {
        defaultColor = .green
        dieOffscreen = true
        // Speed: 1.0 cell/tick -> 30 cells/sec
        callbackArgs = [1.0, 0.0, 1.0, 0.0]
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let args = callbackArgs, args.count >= 3 else { return nil }

        let speed = args[0] as? Double ?? 0.0
        let dy = (group?.state ?? .descending) == .descending ? 1.0 : -1.0

        let gridSpeed = speed * 30.0
        let movementThisFrame = gridSpeed * dy * deltaTime

        let newY = Double(position.y) + movementThisFrame

        if (group?.state ?? .descending) == .descending {
            // Synchronized with hook's max depth logic
            let maxHeight = Double(gridHeight) * 0.75
            // Line should stop when its bottom reaches the hook's top
            if newY + Double(size.height) > maxHeight {
                return Position3D(position.x, Int(maxHeight - Double(size.height)), position.z)
            }
        }

        return Position3D(position.x, Int(newY), position.z)
    }
}
