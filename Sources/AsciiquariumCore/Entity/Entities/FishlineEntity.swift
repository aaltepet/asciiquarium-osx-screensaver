//
//  FishlineEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

public class FishlineEntity: BaseEntity {
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
    }
}
