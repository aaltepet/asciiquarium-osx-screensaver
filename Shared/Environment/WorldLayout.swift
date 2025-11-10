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

    // Underwater entities (back-to-front): castle < seaweed < fish
    static let castle: Int = 1
    static let seaweed: Int = 2
    static let shark: Int = 2
    static let fishStart: Int = 3
    static let fishEnd: Int = 20
}

// MARK: - Spawn Configuration (matching Perl values)
enum SpawnConfig {
    // Fish density: Perl uses int((height - 9) * width / 350)
    // This divisor controls how many fish spawn initially based on screen size
    static let fishDensityDivisor: Int = 350

    // Seaweed count: Perl uses int(width / 15)
    // This divisor controls how many seaweed spawn based on screen width
    static let seaweedCountDivisor: Int = 15

    // Surface region height (rows 0-8, so 9 rows total above water)
    // Used in fish density calculation: (height - 9) excludes surface region
    static let surfaceRegionHeight: Int = 9
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

    /// Safe bottom Y for anchoring entities - ensures entities don't extend below visible area
    /// Use gridHeight - 2 to provide a safety margin for entities that might extend beyond their anchor point
    var safeBottomY: Int { max(0, gridHeight - 2) }

    var bottomRows: ClosedRange<Int> {
        return bottomY...bottomY
    }

    // Convenience spawn helpers
    // Minimum Y (top) for fish spawning: below the surface
    var fishSpawnMinY: Int { max(waterRows.lowerBound, 9) }

    // Keep fish at least this many rows above the very bottom when spawning
    var fishSpawnBottomMarginRows: Int { 2 }

    // Maximum allowed bottom Y for a fish (its bottom edge must be <= this)
    var fishSpawnMaxBottomY: Int { max(0, bottomY - fishSpawnBottomMarginRows) }

    // For 1-row tall entities, this is also the maximum top Y
    var fishSpawnMaxY: Int { max(fishSpawnMinY, fishSpawnMaxBottomY) }
}
