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
        while frame < 20 && bubble.isAlive {
            positions.append((frame: frame, y: bubble.position.y, isAlive: bubble.isAlive))
            engine.tickOnceForTests()
            frame += 1

            // Get updated bubble
            if let updatedBubble = engine.entities.first(where: { $0.id == bubbleId })
                as? BubbleEntity
            {
                if !updatedBubble.isAlive {
                    positions.append((frame: frame, y: updatedBubble.position.y, isAlive: false))
                    break
                }
            } else {
                // Bubble was removed
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
}
