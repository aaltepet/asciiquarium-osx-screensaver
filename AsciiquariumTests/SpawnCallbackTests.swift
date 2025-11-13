//
//  SpawnCallbackTests.swift
//  AsciiquariumTests
//
//  Created by Test on 9/19/25.
//

import Testing

struct SpawnCallbackTests {

    @Test func testSpawnCallbackIsSetOnEntities() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()

        // When - entities are created and engine updates
        engine.tickOnceForTests()

        // Then - all entities should have spawn callback set
        for entity in engine.entities {
            #expect(
                entity.spawnCallback != nil, "Entity \(entity.name) should have spawn callback set")
        }
    }

    @Test func testFishCanSpawnBubbles() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()

        // Find a fish entity
        let fish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(fish != nil, "Engine should have at least one fish")

        // Ensure fish has spawn callback (it should be set during engine updates, but ensure it's set)
        // The engine's updateEntities sets spawn callbacks, so we need to do one update first
        engine.tickOnceForTests()

        // Now get the fish again to ensure it has the spawn callback
        let updatedFish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(updatedFish != nil, "Fish should still exist after update")
        #expect(updatedFish!.spawnCallback != nil, "Fish should have spawn callback set")

        let initialBubbleCount = engine.entities.filter { $0.type == .bubble }.count

        // When - force bubble generation by setting 100% chance and updating many times
        updatedFish!.bubbleChance = 1.0  // 100% chance for testing
        for _ in 0..<10 {
            engine.tickOnceForTests()
        }

        // Then - should have spawned at least one bubble
        let finalBubbleCount = engine.entities.filter { $0.type == .bubble }.count
        #expect(
            finalBubbleCount > initialBubbleCount,
            "Fish should spawn bubbles. Initial: \(initialBubbleCount), Final: \(finalBubbleCount)")
    }

    @Test func testSpawnedBubblesHaveSpawnCallback() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let fish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(fish != nil, "Engine should have at least one fish")

        // When - force bubble generation
        fish?.bubbleChance = 1.0
        engine.tickOnceForTests()

        // Then - spawned bubbles should have spawn callback set
        let bubbles = engine.entities.filter { $0.type == .bubble }
        for bubble in bubbles {
            #expect(bubble.spawnCallback != nil, "Spawned bubble should have spawn callback set")
        }
    }

    @Test func testBubblePositionIsRelativeToFish() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        // Clear initial entities and create a single fish for testing
        engine.entities.removeAll()

        // Create a fish at a known position for testing
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)
        let testFish = EntityFactory.createFish(
            at: Position3D(10, layout.fishSpawnMinY, Depth.fishStart))
        testFish.direction = 1  // Moving right
        testFish.speed = 1.0
        testFish.callbackArgs = [testFish.speed, Double(testFish.direction), 0.0, 0.0]

        // Ensure fish has spawn callback
        testFish.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = testFish.spawnCallback
        }

        engine.entities.append(testFish)

        // Store fish properties before update
        let fishId = testFish.id
        let fishDirection = testFish.direction
        let fishSize = testFish.size

        // When - force bubble generation
        testFish.bubbleChance = 1.0
        engine.tickOnceForTests()

        // Then - bubble should be positioned relative to fish
        // Get fish position AFTER update (fish moves during update, bubble is generated after movement)
        let updatedFish = engine.entities.first { $0.id == fishId } as? FishEntity
        #expect(updatedFish != nil, "Fish should still exist after update")
        let fishPosition = updatedFish!.position

        let bubbles = engine.entities.filter { $0.type == .bubble }
        #expect(bubbles.count > 0, "Should have spawned at least one bubble")

        if let bubble = bubbles.first {
            // Bubble should be at fish's z - 1 (above fish)
            #expect(
                bubble.position.z == fishPosition.z - 1,
                "Bubble z should be one level above fish. Fish z: \(fishPosition.z), Bubble z: \(bubble.position.z)"
            )

            // Bubble x should be at fish's edge based on direction
            let expectedX = fishDirection > 0 ? fishPosition.x + fishSize.width : fishPosition.x
            #expect(
                bubble.position.x == expectedX,
                "Bubble x should be at fish edge. Expected: \(expectedX), Got: \(bubble.position.x), Direction: \(fishDirection), Fish x: \(fishPosition.x)"
            )

            // Bubble y should be at fish's vertical center
            // Note: Bubble moves up by 1 in its first update, so we need to account for that
            let expectedYAtCreation = fishPosition.y + fishSize.height / 2
            let expectedYAfterFirstUpdate = expectedYAtCreation - 1  // Bubble moves up by 1
            #expect(
                bubble.position.y == expectedYAfterFirstUpdate,
                "Bubble y should be at fish center (minus 1 for first movement). Expected: \(expectedYAfterFirstUpdate), Got: \(bubble.position.y), Fish y: \(fishPosition.y), Fish height: \(fishSize.height)"
            )
        }
    }

    @Test func testSpawnedEntitiesAreAddedToEngine() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let initialEntityCount = engine.entities.count

        // When - fish spawns bubble
        let fish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(fish != nil, "Engine should have at least one fish")
        fish!.bubbleChance = 1.0
        engine.tickOnceForTests()

        // Then - entity count should increase
        let finalEntityCount = engine.entities.count
        #expect(
            finalEntityCount > initialEntityCount,
            "Spawned entities should be added to engine. Initial: \(initialEntityCount), Final: \(finalEntityCount)"
        )
    }
}
