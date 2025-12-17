//
//  WorldLayout.swift
//  Asciiquarium
//
//  Centralized depth map and fixed region boundaries.
//

import Foundation

// MARK: - Depth Map (z-order)
public enum Depth {
    // Waterline and gaps (match Perl semantics)
    public static let waterLine3: Int = 2
    public static let waterGap3: Int = 3
    public static let waterLine2: Int = 4
    public static let waterGap2: Int = 5
    public static let waterLine1: Int = 6
    public static let waterGap1: Int = 7
    public static let waterLine0: Int = 8
    public static let waterGap0: Int = 9

    // Underwater entities (back-to-front): castle < seaweed < fish
    public static let castle: Int = 1
    public static let seaweed: Int = 2
    public static let shark: Int = 2
    public static let fishStart: Int = 3
    public static let fishEnd: Int = 20
}

// MARK: - Spawn Configuration (matching Perl values)
public enum SpawnConfig {
    // Fish density: Perl uses int((height - 9) * width / 350)
    // This divisor controls how many fish spawn initially based on screen size
    public static let fishDensityDivisor: Int = 350

    // Seaweed count: Perl uses int(width / 15)
    // This divisor controls how many seaweed spawn based on screen width
    public static let seaweedCountDivisor: Int = 15

    // Surface region height (rows 0-8, so 9 rows total above water)
    // Used in fish density calculation: (height - 9) excludes surface region
    public static let surfaceRegionHeight: Int = 9
}

// MARK: - Fixed Region Boundaries (y coordinates)
public struct WorldLayout {
    public let gridWidth: Int
    public let gridHeight: Int

    public init(gridWidth: Int, gridHeight: Int) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
    }

    // Fixed rows based on project plan
    // sky:    0...4
    // surface:5...8  (4 rows)
    // water:  9...(gridHeight-1)
    // bottom: last row(s) used by bottom entities

    public var surfaceTopY: Int { 5 }
    public var surfaceRows: ClosedRange<Int> { 5...8 }

    public var skyRows: ClosedRange<Int> {
        return 0...(surfaceTopY - 1)
    }

    public var waterRows: ClosedRange<Int> {
        let start = (surfaceRows.upperBound + 1)
        return start...max(start, gridHeight - 1)
    }

    public var bottomY: Int { max(0, gridHeight - 1) }

    /// Safe bottom Y for anchoring entities - ensures entities don't extend below visible area
    /// Use gridHeight - 2 to provide a safety margin for entities that might extend beyond their anchor point
    public var safeBottomY: Int { max(0, gridHeight - 2) }

    public var bottomRows: ClosedRange<Int> {
        return bottomY...bottomY
    }

    // Convenience spawn helpers
    // Minimum Y (top) for fish spawning: below the surface
    public var fishSpawnMinY: Int { max(waterRows.lowerBound, 9) }

    // Keep fish at least this many rows above the very bottom when spawning
    public var fishSpawnBottomMarginRows: Int { 2 }

    // Maximum allowed bottom Y for a fish (its bottom edge must be <= this)
    public var fishSpawnMaxBottomY: Int { max(0, bottomY - fishSpawnBottomMarginRows) }

    // For 1-row tall entities, this is also the maximum top Y
    public var fishSpawnMaxY: Int { max(fishSpawnMinY, fishSpawnMaxBottomY) }
}
