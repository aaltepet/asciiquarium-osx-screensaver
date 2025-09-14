//
//  WaterlineEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Waterline Entity
class WaterlineEntity: EntityFullWidth {
    private var cachedWaterline: [String]?
    private var cachedWidth: Int = 0

    private static var baseSegments = [
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "^^^^ ^^^  ^^^   ^^^    ^^^^      ",
        "^^^^      ^^^^     ^^^    ^^     ",
        "^^      ^^^^      ^^^    ^^^^^^  ",
    ]

    init(name: String, position: Position3D, segmentIndex: Int? = nil) {
        // Use provided segmentIndex or generate random variation
        let actualSegmentIndex = segmentIndex ?? Int.random(in: 0..<4)
        let waterlineSegment = WaterlineEntity.createWaterlineSegment(segmentIndex: 0)
        super.init(name: name, type: .waterline, shape: ["~"], position: position)

        isPhysical = true
        defaultColor = .cyan
        // Waterlines don't move
    }

    private static func createWaterlineSegment(segmentIndex: Int) -> [String] {

        guard segmentIndex < self.baseSegments.count else {
            return [baseSegments[0]]
        }

        return [baseSegments[segmentIndex]]
    }

    override func getShape(for width: Int) -> [String] {
        // Use cached waterline if available and width hasn't changed
        if let cached = cachedWaterline, cachedWidth == width {
            return cached
        }

        // Generate waterline pattern using random segments for each repetition
        let segmentSize = WaterlineEntity.baseSegments[0].count  // All segments should be same size
        let repeatCount = (width / segmentSize) + 1

        var tiledShape = ""
        for _ in 0..<repeatCount {
            let randomSegmentIndex = Int.random(in: 0..<WaterlineEntity.baseSegments.count)
            let randomSegment = WaterlineEntity.baseSegments[randomSegmentIndex]
            tiledShape += randomSegment
        }

        let truncatedShape = String(tiledShape.prefix(width))

        // Cache the result
        let result = [truncatedShape]
        cachedWaterline = result
        cachedWidth = width

        return result
    }

}
