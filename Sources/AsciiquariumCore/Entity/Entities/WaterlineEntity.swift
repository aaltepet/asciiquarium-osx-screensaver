//
//  WaterlineEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Waterline Entity
public class WaterlineEntity: EntityFullWidth {
    private var cachedWaterline: [String]?
    private var cachedWidth: Int = 0
    private let segmentIndex: Int

    private static var baseSegments = [
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
        "^^^^ ^^^  ^^^   ^^^    ^^^^      ",
        "^^^^      ^^^^     ^^^    ^^     ",
        "^^      ^^^^      ^^^    ^^^^^^  ",
    ]

    public init(name: String, position: Position3D, segmentIndex: Int) {
        self.segmentIndex = max(0, min(segmentIndex, WaterlineEntity.baseSegments.count - 1))
        super.init(name: name, type: .waterline, shape: ["~"], position: position)

        isPhysical = true
        defaultColor = .cyan
        // Waterlines don't move
    }

    private func canonicalSegment() -> String { WaterlineEntity.baseSegments[self.segmentIndex] }

    public override func getShape(for width: Int) -> [String] {
        // Use cached waterline if available and width hasn't changed
        if let cached = cachedWaterline, cachedWidth == width {
            return cached
        }

        // Generate waterline pattern using the fixed canonical segment for this row
        let segment = canonicalSegment()
        let segmentSize = segment.count  // All segments should be same size
        let repeatCount = (width / segmentSize) + 1

        let tiledShape = String(repeating: segment, count: repeatCount)

        let truncatedShape = String(tiledShape.prefix(width))

        // Cache the result
        let result = [truncatedShape]
        cachedWaterline = result
        cachedWidth = width

        return result
    }

}
