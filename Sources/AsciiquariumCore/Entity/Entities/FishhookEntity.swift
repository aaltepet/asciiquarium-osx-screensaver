//
//  FishhookEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class FishhookEntity: BaseEntity {
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
    }
}
