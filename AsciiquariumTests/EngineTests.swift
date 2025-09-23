//
//  EngineTests.swift
//  AsciiquariumTests
//
//  Created by Test on 9/19/25.
//

import Testing

struct EngineTests {

    @Test func testEngineInitializesFourWaterlineRows() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()

        // When
        // Engine initializes in init(); verify four rows exist
        let waterlines = engine.entities.filter { $0.type == .waterline }

        // Then
        #expect(waterlines.count == 4, "Engine should create four waterline rows")
        // Verify y positions and z mapping and segment indices 0..3
        let expected: [(y: Int, z: Int)] = [
            (5, Depth.waterLine3),
            (6, Depth.waterLine2),
            (7, Depth.waterLine1),
            (8, Depth.waterLine0),
        ]

        for (y, z) in expected {
            let hasMatch = waterlines.contains { wl in wl.position.y == y && wl.position.z == z }
            #expect(hasMatch, "Missing waterline at y=\(y), z=\(z)")
        }
    }

    @Test func testSpawnedFishRespectWaterRegionAndDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()

        // When
        // Force a few spawns
        for _ in 0..<5 {
            engine.updateGridDimensions(width: engine.gridWidth, height: engine.gridHeight)
        }

        let fish = engine.entities.filter { $0.type == .fish }

        // Then
        for f in fish {
            #expect(f.position.y >= 9, "Fish should spawn at y ≥ 9, got y=\(f.position.y)")
            #expect(
                (Depth.fishStart...Depth.fishEnd).contains(f.position.z),
                "Fish z should be within [\(Depth.fishStart), \(Depth.fishEnd)], got z=\(f.position.z)"
            )
        }
    }
}
