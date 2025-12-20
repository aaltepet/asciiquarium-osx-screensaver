//
//  HookPointEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class HookPointEntity: BaseEntity {
    public var group: FishingGroup?
    public var gridHeight: Int = 24

    public init(name: String, position: Position3D) {
        let pointShape = [
            ".",
            " ",
            "\\",
            " ",
        ]
        super.init(name: name, type: .hookPoint, shape: pointShape, position: position)
        setupHookPoint()
    }

    private func setupHookPoint() {
        isPhysical = true
        defaultColor = .green
        dieOffscreen = true
        transparentChar = " "
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
            // HookPoint is offset relative to hook. Hook height is 6.
            // Perl: hook at $y, point at $y + 2.
            // So point stops at (gridHeight * 0.75 - hook.height) + 2
            let maxPointY = Double(gridHeight) * 0.75 - 6.0 + 2.0
            if newY > maxPointY {
                return Position3D(position.x, Int(maxPointY), position.z)
            }
        }

        return Position3D(position.x, Int(newY), position.z)
    }
}
