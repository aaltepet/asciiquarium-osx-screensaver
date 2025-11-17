//
//  CollisionTests.swift
//  AsciiquariumTests
//
//  Created by Test on 11/15/25.
//

import Testing

struct CollisionTests {

    @Test func testBubbleCollisionHandlerIsSet() async throws {
        // Given
        let bubble = EntityFactory.createBubble(at: Position3D(10, 10, 10))

        // Then
        #expect(bubble.isPhysical == true, "Bubble should be physical")
        #expect(bubble.collisionHandler != nil, "Bubble should have collision handler set")
    }

    @Test func testBubbleDiesWhenCollidingWithWaterline() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let gridWidth = engine.gridWidth
        let waterlineY = 5  // Position waterline at y=5
        let waterlineZ = Depth.waterLine0

        // Create a waterline at the surface
        let waterline = EntityFactory.createWaterline(
            at: Position3D(0, waterlineY, waterlineZ), segmentIndex: 0)
        engine.entities.append(waterline)

        // Create a bubble just below the waterline (at y=6, will move up to y=5)
        let bubble = EntityFactory.createBubble(at: Position3D(10, 6, waterlineZ - 1))
        bubble.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = bubble.spawnCallback
        }
        engine.entities.append(bubble)

        // Verify bubble is alive initially
        #expect(bubble.isAlive == true, "Bubble should be alive initially")

        // When - update engine (bubble moves up and collides with waterline)
        engine.tickOnceForTests()

        // Then - bubble should be dead after collision
        #expect(
            bubble.isAlive == false,
            "Bubble should die when colliding with waterline. Bubble position: \(bubble.position), Waterline y: \(waterlineY)"
        )
    }

    @Test func testBubbleRisesAndCollidesWithWaterline() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let gridWidth = engine.gridWidth
        let waterlineY = 5
        let waterlineZ = Depth.waterLine0

        // Create a waterline
        let waterline = EntityFactory.createWaterline(
            at: Position3D(0, waterlineY, waterlineZ), segmentIndex: 0)
        engine.entities.append(waterline)

        // Create a bubble well below the waterline
        let bubbleStartY = 10
        let bubble = EntityFactory.createBubble(at: Position3D(10, bubbleStartY, waterlineZ - 1))
        bubble.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = bubble.spawnCallback
        }
        engine.entities.append(bubble)

        let bubbleId = bubble.id

        // Track bubble position as it rises
        var positions: [(frame: Int, y: Int, isAlive: Bool)] = []
        var frame = 0

        // When - update until bubble collides or moves too far
        while frame < 20 {
            engine.tickOnceForTests()
            frame += 1

            // Get updated bubble state AFTER the update
            if let updatedBubble = engine.entities.first(where: { $0.id == bubbleId })
                as? BubbleEntity
            {
                // Record position after update
                positions.append(
                    (frame: frame, y: updatedBubble.position.y, isAlive: updatedBubble.isAlive))
                if !updatedBubble.isAlive {
                    break
                }
            } else {
                // Bubble was removed (it's dead)
                // Try to get the last known position from the bubble reference
                positions.append((frame: frame, y: bubble.position.y, isAlive: false))
                break
            }
        }

        // Then - bubble should have risen and died when reaching waterline
        #expect(
            positions.count > 0,
            "Should have tracked bubble movement. Positions: \(positions)"
        )

        if let lastPosition = positions.last {
            #expect(
                lastPosition.isAlive == false,
                "Bubble should be dead after collision. Last position: y=\(lastPosition.y), waterline y=\(waterlineY)"
            )

            // Bubble should have died at or just before reaching waterline
            // (it moves up by 1 each frame, so it should die when y == waterlineY)
            #expect(
                lastPosition.y <= waterlineY,
                "Bubble should die at or before reaching waterline. Last y: \(lastPosition.y), waterline y: \(waterlineY)"
            )
        }
    }

    @Test func testBubbleDoesNotDieWhenNotColliding() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let waterlineY = 5
        let waterlineZ = Depth.waterLine0

        // Create a waterline
        let waterline = EntityFactory.createWaterline(
            at: Position3D(0, waterlineY, waterlineZ), segmentIndex: 0)
        engine.entities.append(waterline)

        // Create a bubble far below the waterline (at y=20)
        let bubble = EntityFactory.createBubble(at: Position3D(10, 20, waterlineZ - 1))
        bubble.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = bubble.spawnCallback
        }
        engine.entities.append(bubble)

        // When - update a few times (bubble rises but doesn't reach waterline yet)
        for _ in 0..<5 {
            engine.tickOnceForTests()
        }

        // Then - bubble should still be alive
        #expect(
            bubble.isAlive == true,
            "Bubble should still be alive when not colliding with waterline. Bubble y: \(bubble.position.y), Waterline y: \(waterlineY)"
        )
    }

    // MARK: - Shark Collision Tests

    @Test func testSharkCollisionHandlerIsSet() async throws {
        // Given
        let shark = EntityFactory.createShark(at: Position3D(0, 10, Depth.shark))

        // Then
        #expect(shark.isPhysical == true, "Shark should be physical")
        #expect(shark.collisionHandler != nil, "Shark should have collision handler set")
    }

    @Test func testSharkKillsFishOnCollision() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        // Create a shark and position fish so their visible pixels overlap
        // Shark has leading spaces, so we position fish inside shark's visible area
        let shark = EntityFactory.createShark(at: Position3D(10, 10, Depth.shark))
        shark.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = shark.spawnCallback
        }
        engine.entities.append(shark)

        // Position fish so it overlaps with shark's visible pixels (shark's visible area starts around x=40)
        let fish = EntityFactory.createFish(at: Position3D(35, 12, Depth.shark))
        fish.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = fish.spawnCallback
        }
        engine.entities.append(fish)

        let fishId = fish.id

        // Verify fish is alive initially
        #expect(fish.isAlive == true, "Fish should be alive initially")

        // When - update engine (collision should be detected)
        engine.tickOnceForTests()

        // Then - fish should be dead after collision
        if let updatedFish = engine.entities.first(where: { $0.id == fishId }) {
            #expect(
                updatedFish.isAlive == false,
                "Fish should be dead after shark collision"
            )
        } else {
            // Fish was removed from entities (also valid - it's dead)
            #expect(true, "Fish was removed after collision (it's dead)")
        }
    }

    @Test func testSharkSpawnsSplatOnFishCollision() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        // Create a shark and position fish so their visible pixels overlap
        let shark = EntityFactory.createShark(at: Position3D(10, 10, Depth.shark))
        shark.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = shark.spawnCallback
        }
        engine.entities.append(shark)

        // Position fish so it overlaps with shark's visible pixels
        let fish = EntityFactory.createFish(at: Position3D(35, 12, Depth.shark))
        fish.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = fish.spawnCallback
        }
        engine.entities.append(fish)

        let initialSplatCount = engine.entities.filter { $0.type == .splat }.count

        // When - update engine (collision should spawn splat)
        engine.tickOnceForTests()

        // Then - should have spawned a splat
        let finalSplatCount = engine.entities.filter { $0.type == .splat }.count
        #expect(
            finalSplatCount > initialSplatCount,
            "Shark should spawn splat on fish collision. Initial: \(initialSplatCount), Final: \(finalSplatCount)"
        )

        // Verify splat properties
        if let splat = engine.entities.first(where: { $0.type == .splat }) as? SplatEntity {
            #expect(splat.defaultColor == .red, "Splat should be red")
            #expect(splat.dieFrame != nil, "Splat should have dieFrame set")
        }
    }

    @Test func testSplatPositionIsRelativeToFish() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let sharkX = 10
        let sharkY = 15
        let fishX = 45  // Position fish so it overlaps with shark's visible pixels
        let fishY = 17  // Slightly offset vertically to ensure overlap
        let fishZ = Depth.shark

        // Create a shark and fish at positions where their visible pixels overlap
        let shark = EntityFactory.createShark(at: Position3D(sharkX, sharkY, fishZ))
        shark.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = shark.spawnCallback
        }
        engine.entities.append(shark)

        let fish = EntityFactory.createFish(at: Position3D(fishX, fishY, fishZ))
        fish.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = fish.spawnCallback
        }
        engine.entities.append(fish)

        // When - update engine (collision should spawn splat)
        engine.tickOnceForTests()

        // Then - splat should be positioned relative to fish (matching Perl: position => [ $x - 4, $y - 2, $z-2 ])
        let splats = engine.entities.filter { $0.type == .splat }
        #expect(splats.count > 0, "Should have spawned at least one splat")

        if let splat = splats.first {
            let expectedX = fishX - 4
            let expectedY = fishY - 2
            let expectedZ = max(0, fishZ - 2)

            #expect(
                splat.position.x == expectedX,
                "Splat x should be fish x - 4. Expected: \(expectedX), Got: \(splat.position.x)"
            )
            #expect(
                splat.position.y == expectedY,
                "Splat y should be fish y - 2. Expected: \(expectedY), Got: \(splat.position.y)"
            )
            #expect(
                splat.position.z == expectedZ,
                "Splat z should be fish z - 2. Expected: \(expectedZ), Got: \(splat.position.z)"
            )
        }
    }

    @Test func testSharkDoesNotCollideWithNonFishEntities() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        // Create a shark and bubble at the same position
        let shark = EntityFactory.createShark(at: Position3D(10, 10, Depth.shark))
        shark.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = shark.spawnCallback
        }
        engine.entities.append(shark)

        let bubble = EntityFactory.createBubble(at: Position3D(10, 10, Depth.shark))
        bubble.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = bubble.spawnCallback
        }
        engine.entities.append(bubble)

        let initialSplatCount = engine.entities.filter { $0.type == .splat }.count

        // When - update engine (shark and bubble collide, but shark only reacts to fish)
        engine.tickOnceForTests()

        // Then - no splat should be spawned (shark doesn't react to bubble)
        let finalSplatCount = engine.entities.filter { $0.type == .splat }.count
        #expect(
            finalSplatCount == initialSplatCount,
            "Shark should not spawn splat for non-fish collisions. Initial: \(initialSplatCount), Final: \(finalSplatCount)"
        )
    }
}
