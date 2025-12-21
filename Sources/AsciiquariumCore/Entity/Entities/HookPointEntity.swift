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
        dieOffscreen = false
        transparentChar = " "
        // Speed: 1.0 cell/tick -> 30 cells/sec
        callbackArgs = [1.0, 0.0, 1.0, 0.0]
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let group = group else { return nil }

        // Follow the group's floating-point Y with fixed offset
        // Perl: hook at $y, point at $y + 2
        let pointY = group.y + 2
        return Position3D(position.x, Int(floor(pointY)), position.z)
    }
}
