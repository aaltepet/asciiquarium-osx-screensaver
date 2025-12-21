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
        // Perl uses 50 lines + 6 spaces. We'll use 100 pipes + 6 spaces.
        var lineShape = Array(repeating: "|", count: 100)
        lineShape.append(contentsOf: Array(repeating: " ", count: 6))
        super.init(name: name, type: .fishline, shape: lineShape, position: position)
        setupFishline()
    }

    private func setupFishline() {
        defaultColor = .green
        dieOffscreen = false
        transparentChar = " "
        // Speed: 1.0 cell/tick -> 30 cells/sec
        callbackArgs = [1.0, 0.0, 1.0, 0.0]
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let group = group else { return nil }

        // Follow the group's floating-point Y with fixed offset
        let lineY = group.y - 100
        return Position3D(position.x, Int(floor(lineY)), position.z)
    }
}
