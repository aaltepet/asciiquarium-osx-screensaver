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

    @Test func testSpawnedFishRespectSpawnBoundsAndDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        // Force a few spawns
        for _ in 0..<5 {
            engine.updateGridDimensions(width: engine.gridWidth, height: engine.gridHeight)
        }

        let fish = engine.entities.filter { $0.type == .fish }

        // Then
        for f in fish {
            // Y within allowed top spawn band
            #expect(
                f.position.y >= layout.fishSpawnMinY,
                "Fish y below min: y=\(f.position.y), min=\(layout.fishSpawnMinY)"
            )

            // Bottom respects required margin from bottom
            let fishBottomY = f.position.y + (f.size.height - 1)
            #expect(
                fishBottomY <= layout.fishSpawnMaxBottomY,
                "Fish bottom too low: bottomY=\(fishBottomY), maxAllowed=\(layout.fishSpawnMaxBottomY), topY=\(f.position.y), height=\(f.size.height)"
            )

            // Z depth within fish range
            #expect(
                (Depth.fishStart...Depth.fishEnd).contains(f.position.z),
                "Fish z should be within [\(Depth.fishStart), \(Depth.fishEnd)], got z=\(f.position.z)"
            )
        }
    }

    @Test func testCastlePlacedBottomRightWithCorrectDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        let castles = engine.entities.filter { $0.type == .castle }

        // Then
        #expect(castles.count == 1, "Exactly one castle should be spawned")
        if let castle = castles.first {
            let expectedBottomY = layout.safeBottomY
            let actualBottomY = castle.position.y + (castle.size.height - 1)
            #expect(actualBottomY == expectedBottomY, "Castle must sit on bottom row")

            let expectedX = max(0, engine.gridWidth - castle.size.width)
            #expect(castle.position.x == expectedX, "Castle should be right-aligned")

            #expect(castle.position.z == Depth.castle, "Castle z-depth mismatch")
        }
    }

    @Test func testSeaweedDistributedAlongBottomWithValidHeights() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        let weeds = engine.entities.filter { $0.type == .seaweed }

        // Then
        let expectedCount = max(1, engine.gridWidth / 15)
        #expect(weeds.count == expectedCount, "Seaweed count should scale with width")

        for w in weeds {
            let bottomY = w.position.y + (w.size.height - 1)
            #expect(bottomY == layout.safeBottomY, "Seaweed should be anchored to safe bottom")
            #expect((3...6).contains(w.size.height), "Seaweed height should be in [3,6]")
            #expect(w.position.z == Depth.seaweed, "Seaweed z-depth mismatch")
            #expect((0..<engine.gridWidth).contains(w.position.x), "Seaweed x within bounds")
        }
    }

    @Test func testBottomDecorReflowsOnResize() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let initialLayout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)
        let initialSeaweedCount = engine.entities.filter { $0.type == .seaweed }.count
        #expect(initialSeaweedCount == max(1, engine.gridWidth / 15))

        // When: increase width and height
        engine.updateGridDimensions(width: engine.gridWidth + 30, height: engine.gridHeight + 10)
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // Then: castle reflow
        if let castle = engine.entities.first(where: { $0.type == .castle }) {
            let bottomY = castle.position.y + (castle.size.height - 1)
            #expect(bottomY == layout.safeBottomY, "Castle should sit on new safe bottom")
            let expectedX = max(0, engine.gridWidth - castle.size.width)
            #expect(castle.position.x == expectedX, "Castle should be re-aligned right")
        } else {
            #expect(false, "Castle should exist after resize")
        }

        // Seaweed reflow
        let weeds = engine.entities.filter { $0.type == .seaweed }
        let expectedCount = max(1, engine.gridWidth / 15)
        #expect(weeds.count == expectedCount, "Seaweed count should reflow with width")
        for w in weeds {
            let bottomY = w.position.y + (w.size.height - 1)
            #expect(
                bottomY == layout.safeBottomY, "Seaweed should be re-anchored to new safe bottom")
            #expect(w.position.z == Depth.seaweed)
        }
    }

}
