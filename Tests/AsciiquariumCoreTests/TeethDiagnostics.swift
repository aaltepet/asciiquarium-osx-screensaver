//
//  TeethDiagnostics.swift
//  AsciiquariumTests
//
//  Diagnostic tests to debug teeth collision issues
//

import Testing

@testable import AsciiquariumCore

struct TeethDiagnostics {

    @Test func testTeethPositioningWithShark() async throws {
        // Given - spawn a shark
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let shark = EntityFactory.createShark(at: Position3D(10, 15, Depth.shark))
        engine.entities.append(shark)

        // When - spawn teeth the way Engine does
        let sharkY = shark.position.y
        let teethY = sharkY + 7
        let teethX = shark.position.x + shark.size.width - 9  // For right-moving shark

        let teeth = EntityFactory.createTeeth(
            at: Position3D(teethX, teethY, Depth.shark - 1),
            speed: shark.speed,
            direction: shark.direction
        )
        teeth.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = teeth.spawnCallback
        }
        engine.entities.append(teeth)

        // Then - verify positions
        // Check if teeth are within shark's bounds
        let sharkTop = shark.position.y
        let sharkBottom = shark.position.y + shark.size.height - 1
        _ = teethY >= sharkTop && teethY <= sharkBottom

        #expect(teeth.isPhysical == true, "Teeth should be physical")
        #expect(teeth.collisionHandler != nil, "Teeth should have collision handler")
    }

    @Test func testTeethAndFishAtSameDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        // Create teeth at depth 1 (as spawned with shark)
        let teeth = EntityFactory.createTeeth(
            at: Position3D(50, 15, Depth.shark - 1),  // depth 1
            speed: 1.0,
            direction: -1
        )
        teeth.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = teeth.spawnCallback
        }
        engine.entities.append(teeth)

        // Create fish at various depths
        for fishZ in Depth.fishStart...Depth.fishEnd {
            let fish = EntityFactory.createFish(at: Position3D(30, 15, fishZ))
            fish.spawnCallback = { [weak engine] newEntity in
                engine?.entities.append(newEntity)
                newEntity.spawnCallback = fish.spawnCallback
            }
            engine.entities.append(fish)

            // Check collision
            let collisions = teeth.checkCollisions(with: engine.entities)
            _ = collisions.first { $0.id == fish.id }
        }
    }

    @Test func testTeethMovementWithShark() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        engine.entities.removeAll()

        let shark = EntityFactory.createShark(at: Position3D(10, 15, Depth.shark))
        shark.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = shark.spawnCallback
        }
        engine.entities.append(shark)

        let teethY = shark.position.y + 7
        let teethX = shark.position.x + shark.size.width - 9
        let teeth = EntityFactory.createTeeth(
            at: Position3D(teethX, teethY, Depth.shark - 1),
            speed: shark.speed,
            direction: shark.direction
        )
        teeth.spawnCallback = { [weak engine] newEntity in
            engine?.entities.append(newEntity)
            newEntity.spawnCallback = teeth.spawnCallback
        }
        engine.entities.append(teeth)

        let initialSharkX = shark.position.x
        let initialTeethX = teeth.position.x
        let expectedOffset = initialTeethX - initialSharkX

        // When - move both
        engine.tickOnceForTests()

        let newSharkX = shark.position.x
        let newTeethX = teeth.position.x
        let newOffset = newTeethX - newSharkX

        // Then - offset should remain constant
        #expect(
            newOffset == expectedOffset,
            "Teeth should maintain same offset from shark. Expected: \(expectedOffset), Got: \(newOffset)"
        )
    }
}
