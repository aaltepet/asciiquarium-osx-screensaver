//
//  SharkEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Shark Entity
class SharkEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .shark, shape: [""], position: position)
        setupShark()
    }

    private func setupShark() {
        isPhysical = true
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [2.0, 1.0, 0.0, 0.0]  // Fast horizontal movement
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Shark moves horizontally
        return Position3D(
            position.x + Int(2.0 * deltaTime),
            position.y,
            position.z
        )
    }
}
