//
//  WorldLayout.swift
//  Asciiquarium
//
//  Centralized depth map and fixed region boundaries.
//

import Foundation

// MARK: - Depth Map (z-order)
enum Depth {
    // Waterline and gaps (match Perl semantics)
    static let waterLine3: Int = 2
    static let waterGap3: Int = 3
    static let waterLine2: Int = 4
    static let waterGap2: Int = 5
    static let waterLine1: Int = 6
    static let waterGap1: Int = 7
    static let waterLine0: Int = 8
    static let waterGap0: Int = 9

    // Underwater entities
    static let fishStart: Int = 3
    static let fishEnd: Int = 20
    static let shark: Int = 2
    static let seaweed: Int = 21
    static let castle: Int = 22
}

// MARK: - Fixed Region Boundaries (y coordinates)
struct WorldLayout {
    let gridWidth: Int
    let gridHeight: Int

    // Fixed rows based on project plan
    // sky:    0...4
    // surface:5...8  (4 rows)
    // water:  9...(gridHeight-1)
    // bottom: last row(s) used by bottom entities

    var surfaceTopY: Int { 5 }
    var surfaceRows: ClosedRange<Int> { 5...8 }

    var skyRows: ClosedRange<Int> {
        return 0...(surfaceTopY - 1)
    }

    var waterRows: ClosedRange<Int> {
        let start = (surfaceRows.upperBound + 1)
        return start...max(start, gridHeight - 1)
    }

    var bottomY: Int { max(0, gridHeight - 1) }

    // Convenience spawn helpers
    var fishSpawnMinY: Int { max(waterRows.lowerBound, 9) }
    var fishSpawnMaxY: Int { max(fishSpawnMinY, bottomY) }
}
