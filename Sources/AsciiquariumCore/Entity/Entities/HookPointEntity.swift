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

        collisionHandler = { [weak self] (point, collidingEntities) in
            guard let self = self, let group = self.group, group.state == .descending else {
                return
            }

            // Find the first fish in the colliding entities
            if let fish = collidingEntities.first(where: { $0.type == .fish }) as? FishEntity {
                // Calculate offset from hook point at moment of catch
                // HookPoint is at self.position
                let offsetX = fish.position.x - self.position.x
                let offsetY = fish.position.y - self.position.y

                // Catch the fish
                group.caughtFish = fish
                fish.setCaught(by: group, offset: (x: offsetX, y: offsetY))
                self.isPhysical = false  // Hook point is no longer physical once it catches something

                // Update fish depth so it appears in front of the hook
                // fishingHook is at waterLine1 + 1 (7), so we'll use + 2 (8)
                fish.position = Position3D(fish.position.x, fish.position.y, Depth.fishingHook + 1)

                // Start retracting
                group.retract()
            }
        }
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        guard let group = group else { return nil }

        // Follow the group's floating-point Y with fixed offset
        // Perl: hook at $y, point at $y + 2
        let pointY = group.y + 2
        return Position3D(position.x, Int(floor(pointY)), position.z)
    }
}
