//
//  PlaceholderEntities.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Placeholder Entities (to be implemented)

public class FishhookEntity: BaseEntity {
    public init(name: String, position: Position3D) {
        super.init(name: name, type: .fishhook, shape: [""], position: position)
        setupFishhook()
    }

    private func setupFishhook() {
        dieOffscreen = true
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]  // Lowering motion
    }
}

public class FishlineEntity: BaseEntity {
    public init(name: String, position: Position3D) {
        super.init(name: name, type: .fishline, shape: [""], position: position)
        setupFishline()
    }

    private func setupFishline() {
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]
    }
}

public class HookPointEntity: BaseEntity {
    public init(name: String, position: Position3D) {
        super.init(name: name, type: .hookPoint, shape: [".", "\\"], position: position)
        setupHookPoint()
    }

    private func setupHookPoint() {
        isPhysical = true
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]
    }
}
