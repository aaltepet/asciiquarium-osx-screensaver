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
    // Note: Sharks don't have collision handlers - the teeth entity handles collisions.
    // See testTeethCollisionWithFish() for collision testing.

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

    // MARK: - Teeth Collision Tests

    @Test func testTeethCollisionWithFish() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        // Set up spawn callback
        var spawnCallback: ((Entity) -> Void)!
        spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = spawnCallback
        }

        // Create teeth moving left (direction = -1) at the right side
        let teethSpeed = 1.0
        let teethDirection = -1  // Moving left
        let teethY = 15  // Vertical position
        let teethZ = Depth.shark  // Same depth as fish
        let teethX = 50  // Start on the right side

        let teeth = EntityFactory.createTeeth(
            at: Position3D(teethX, teethY, teethZ),
            speed: teethSpeed,
            direction: teethDirection
        )
        teeth.spawnCallback = spawnCallback
        engine.entities.append(teeth)

        // Create a fish moving right (direction = 1) at the same vertical alignment
        let fish = EntityFactory.createFish(at: Position3D(10, teethY, teethZ))
        // Force fish to move right
        fish.direction = 1
        fish.speed = 0.5  // Slower speed to ensure collision happens
        fish.callbackArgs = [fish.speed, Double(fish.direction), 0.0, 0.0]
        fish.spawnCallback = spawnCallback
        engine.entities.append(fish)

        let fishId = fish.id
        let teethId = teeth.id

        // Verify initial state
        #expect(fish.isAlive == true, "Fish should be alive initially")
        #expect(teeth.isAlive == true, "Teeth should be alive initially")
        let initialSplatCount = engine.entities.filter { $0.type == .splat }.count
        #expect(initialSplatCount == 0, "Should start with no splats")

        // When - run engine until splat is detected or timeout
        var frame = 0
        let maxFrames = 200  // Safety timeout
        var splatDetected = false

        while frame < maxFrames {
            engine.tickOnceForTests()
            frame += 1

            // Check if a splat was spawned
            let splatCount = engine.entities.filter { $0.type == .splat }.count
            if splatCount > initialSplatCount {
                splatDetected = true
                break
            }

            // Check if fish is dead (collision happened)
            if let updatedFish = engine.entities.first(where: { $0.id == fishId }) {
                if !updatedFish.isAlive {
                    // Fish is dead, check if splat was created
                    let currentSplatCount = engine.entities.filter { $0.type == .splat }.count
                    if currentSplatCount > initialSplatCount {
                        splatDetected = true
                    }
                    break
                }
            } else {
                // Fish was removed (it's dead)
                let currentSplatCount = engine.entities.filter { $0.type == .splat }.count
                if currentSplatCount > initialSplatCount {
                    splatDetected = true
                }
                break
            }
        }

        // Then - splat should be detected
        #expect(
            splatDetected == true,
            "Splat should be detected after collision. Frame: \(frame), Max frames: \(maxFrames)"
        )

        // Verify splat was created
        let finalSplatCount = engine.entities.filter { $0.type == .splat }.count
        #expect(
            finalSplatCount > initialSplatCount,
            "Should have spawned a splat. Initial: \(initialSplatCount), Final: \(finalSplatCount)"
        )

        // Verify fish is dead
        if let updatedFish = engine.entities.first(where: { $0.id == fishId }) {
            #expect(updatedFish.isAlive == false, "Fish should be dead after collision")
        } else {
            // Fish was removed (also valid - it's dead)
            #expect(true, "Fish was removed after collision (it's dead)")
        }
    }
}
