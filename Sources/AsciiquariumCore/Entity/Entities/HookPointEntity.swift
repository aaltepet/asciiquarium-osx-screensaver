//
//  HookPointEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class HookPointEntity: BaseEntity {
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
    }
}
