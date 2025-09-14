//
//  WaterlineEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Waterline Entity
class WaterlineEntity: BaseEntity {
    init(name: String, position: Position3D, segmentIndex: Int) {
        let waterlineSegment = WaterlineEntity.createWaterlineSegment(segmentIndex: segmentIndex)
        super.init(name: name, type: .waterline, shape: waterlineSegment, position: position)
        setupWaterline()
    }

    private func setupWaterline() {
        isPhysical = true
        defaultColor = .cyan
        // Waterlines don't move
    }

    private static func createWaterlineSegment(segmentIndex: Int) -> [String] {
        let baseSegments = [
            "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
            "^^^^ ^^^  ^^^   ^^^    ^^^^      ",
            "^^^^      ^^^^     ^^^    ^^     ",
            "^^      ^^^^      ^^^    ^^^^^^  ",
        ]

        guard segmentIndex < baseSegments.count else {
            return [baseSegments[0]]
        }

        return [baseSegments[segmentIndex]]
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil  // Waterlines are static
    }

    func tileAcrossWidth(_ width: Int) {
        let segmentSize = shape[0].count
        let repeatCount = (width / segmentSize) + 1

        if let baseSegment = shape.first {
            shape = [String(repeating: baseSegment, count: repeatCount)]
        }
    }
}
