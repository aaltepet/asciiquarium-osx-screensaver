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

        let initialBubbleCount = engine.entities.filter { $0.type == .bubble }.count

        // When - force bubble generation by setting 100% chance and updating many times
        // We'll update many times to increase probability of bubble generation
        // (3% chance per frame means ~30 frames should give us high probability)
        fish?.bubbleChance = 1.0  // 100% chance for testing
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
        let fish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(fish != nil, "Engine should have at least one fish")

        let fishPosition = fish!.position
        let fishSize = fish!.size
        let fishDirection = fish!.direction

        // When - force bubble generation
        fish!.bubbleChance = 1.0
        engine.tickOnceForTests()

        // Then - bubble should be positioned relative to fish
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
                "Bubble x should be at fish edge. Expected: \(expectedX), Got: \(bubble.position.x), Direction: \(fishDirection)"
            )

            // Bubble y should be at fish's vertical center
            let expectedY = fishPosition.y + fishSize.height / 2
            #expect(
                bubble.position.y == expectedY,
                "Bubble y should be at fish center. Expected: \(expectedY), Got: \(bubble.position.y)"
            )
        }
    }

    @Test func testBubbleSpawnRateMatchesPerl() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let fish = engine.entities.first { $0.type == .fish } as? FishEntity
        #expect(fish != nil, "Engine should have at least one fish")

        // Reset to Perl's 3% chance
        fish!.bubbleChance = 0.03

        // When - update many frames (100 frames with 3% chance should give us ~3 bubbles on average)
        var bubbleCount = 0
        for _ in 0..<100 {
            let beforeCount = engine.entities.filter { $0.type == .bubble }.count
            engine.tickOnceForTests()
            let afterCount = engine.entities.filter { $0.type == .bubble }.count
            if afterCount > beforeCount {
                bubbleCount += 1
            }
        }

        // Then - should have spawned some bubbles (with 3% chance over 100 frames, we expect ~3)
        // We'll be lenient: at least 1 bubble in 100 frames is reasonable
        #expect(
            bubbleCount >= 1,
            "Should spawn bubbles with 3% chance. Spawned \(bubbleCount) bubbles in 100 frames")
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
