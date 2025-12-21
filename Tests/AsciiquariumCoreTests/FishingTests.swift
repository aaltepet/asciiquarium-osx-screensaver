import Foundation
import Testing

@testable import AsciiquariumCore

@Suite("Fishing Movement Tests")
struct FishingTests {

    @Test func testFishingGroupSynchronization() async throws {
        let group = FishingGroup()
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 0, 0))
        let line = FishlineEntity(name: "line", position: Position3D(16, -100, 0))
        let point = HookPointEntity(name: "point", position: Position3D(11, 2, 0))

        hook.group = group
        line.group = group
        point.group = group
        group.y = 0.0

        // Initial state: descending
        #expect(group.state == .descending)

        // Move one tick (1/30 sec)
        let deltaTime: TimeInterval = 1.0 / 30.0

        // hook is the leader, it updates group.y
        let newHookPos = hook.moveEntity(deltaTime: deltaTime)
        // Followers use the updated group.y
        let newLinePos = line.moveEntity(deltaTime: deltaTime)
        let newPointPos = point.moveEntity(deltaTime: deltaTime)

        // group.y should now be 1.0 (speed 1.0 * 30 FPS * 1/30 sec = 1.0)
        #expect(group.y == 1.0)
        #expect(newHookPos?.y == 1)
        #expect(newLinePos?.y == -99)  // 1.0 - 100
        #expect(newPointPos?.y == 3)  // 1.0 + 2

        // Switch to retracting
        group.retract()
        #expect(group.state == .retracting)

        // Move another tick
        let retractHookPos = hook.moveEntity(deltaTime: deltaTime)
        let retractLinePos = line.moveEntity(deltaTime: deltaTime)
        let retractPointPos = point.moveEntity(deltaTime: deltaTime)

        // group.y should now be 0.0 (1.0 - 1.0)
        #expect(group.y == 0.0)
        #expect(retractHookPos?.y == 0)
        #expect(retractLinePos?.y == -100)
        #expect(retractPointPos?.y == 2)
    }

    @Test func testFishCatching() async throws {
        let engine = AsciiquariumEngine()
        engine.entities.removeAll()

        let (group, hook, _, point) = EntityFactory.createFishingAssembly(
            atX: 20, y: 10, gridHeight: 40)
        group.y = 10.0
        engine.entities.append(contentsOf: [hook, point])

        // Hook point is at (21, 12).
        // In first tick, it will move to y=13.
        let fish = FishEntity(name: "target_fish", position: Position3D(20, 14, Depth.fishStart))
        fish.shape = ["XXX", "XXX", "XXX"]
        fish.colorMask = nil
        fish.transparentChar = nil
        fish.speed = 0.0
        fish.callbackArgs = [0.0, 0.0, 0.0, 0.0]
        engine.entities.append(fish)

        // Run one tick
        engine.tickOnceForTests()

        // The engine update loop handles collisions.
        #expect(group.state == .retracting)
        #expect(group.caughtFish === fish)
        #expect(fish.caughtBy === group)
        #expect(fish.isPhysical == false)
        #expect(fish.position.z == Depth.fishingHook + 1)
        #expect(point.isPhysical == false)

        // Next tick: reeling in (group.y goes from 11.0 down to 10.0)
        engine.tickOnceForTests()

        #expect(group.y == 10.0)
        #expect(hook.position.y == 10)
        #expect(point.position.y == 12)  // floor(10.0) + 2

        // Original catch: point was at (21, 13), fish was at (20, 14).
        // Offset: (20-21=-1, 14-13=1)
        // New fish pos: point.x - 1 = 20, point.y + 1 = 13
        #expect(fish.position.x == 20)
        #expect(fish.position.y == 13)
    }

    @Test func testMaxDepthLogic() async throws {
        let group = FishingGroup()
        let gridHeight = 24

        // Place hook near max depth
        // Hook height is 6. If bottom (y + 6) is at 18, y = 12.
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 11, 0))
        hook.group = group
        hook.gridHeight = gridHeight
        group.y = 11.0

        let deltaTime: TimeInterval = 1.0 / 30.0

        // Move down by 1 cell
        let newPos1 = hook.moveEntity(deltaTime: deltaTime)
        #expect(newPos1?.y == 12)  // Now at max depth (12 + 6 = 18)

        // Try to move down again
        hook.position = newPos1!
        let newPos2 = hook.moveEntity(deltaTime: deltaTime)
        #expect(newPos2?.y == 12)  // Should NOT move further down
    }

    @Test func testLineStopAtHookTop() async throws {
        let group = FishingGroup()
        let gridHeight = 24
        // Hook top stops at 18 - 6 = 12.
        // Line height is 106 (100 pipes + 6 spaces).
        // Line bottom should stop at 18.
        // Line top should be at 18 - 106 = -88.

        let line = FishlineEntity(name: "line", position: Position3D(10, -89, 0))
        line.group = group
        line.gridHeight = gridHeight
        // The line follows group.y. If line is at -89 and offset is -100, group.y must be 11.0
        group.y = 11.0

        let deltaTime: TimeInterval = 1.0 / 30.0

        // We need the leader (hook) to move the group
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 11, 0))
        hook.group = group
        hook.gridHeight = gridHeight

        _ = hook.moveEntity(deltaTime: deltaTime)
        let newPos = line.moveEntity(deltaTime: deltaTime)
        #expect(newPos?.y == -88)  // group.y became 12.0, line is 12.0 - 100 = -88

        line.position = newPos!
        _ = hook.moveEntity(deltaTime: deltaTime)  // Try to move hook further
        let newPos2 = line.moveEntity(deltaTime: deltaTime)
        #expect(newPos2?.y == -88)  // Should stay clamped because hook stayed clamped
    }

    @Test func testTimedRetraction() async throws {
        let group = FishingGroup()
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 12, 0))  // Already at max depth (12+6=18)
        hook.group = group
        hook.gridHeight = 24

        #expect(group.state == .descending)

        // Update for 29 seconds - should still be descending
        hook.update(deltaTime: 29.0)
        #expect(group.state == .descending)

        // Update for another 2 seconds - total 31 seconds - should be retracting
        hook.update(deltaTime: 2.0)
        #expect(group.state == .retracting)
    }

    @Test func testSpawnFishhook() async throws {
        let engine = AsciiquariumEngine()
        engine.entities.removeAll()

        // When
        engine.spawnFishhook()

        // Then
        let entities = engine.entities
        #expect(entities.count == 3)

        let hook = entities.first(where: { $0.type == .fishhook }) as? FishhookEntity
        let line = entities.first(where: { $0.type == .fishline }) as? FishlineEntity
        let point = entities.first(where: { $0.type == .hookPoint }) as? HookPointEntity

        #expect(hook != nil)
        #expect(line != nil)
        #expect(point != nil)

        // Verify group linkage
        #expect(hook?.group === line?.group)
        #expect(hook?.group === point?.group)
        #expect(hook?.group != nil)

        // Verify FishingGroup references are set
        #expect(hook?.group?.hook === hook)
        #expect(hook?.group?.line === line)
        #expect(hook?.group?.point === point)

        // Verify initial positions
        #expect(hook?.position.y == -4)
        #expect(line?.position.y == -104)
        #expect(point?.position.y == -2)

        if let hookX = hook?.position.x, let lineX = line?.position.x,
            let pointX = point?.position.x
        {
            #expect(hookX == lineX - 6)
            #expect(hookX == pointX - 1)
        } else {
            #expect(Bool(false), "Entities should have X positions")
        }
    }

    @Test func testGroupCleanupOnDeath() async throws {
        let engine = AsciiquariumEngine()
        engine.entities.removeAll()
        engine.spawnFishhook()

        let entities = engine.entities
        let hook = entities.first(where: { $0.type == .fishhook })
        let line = entities.first(where: { $0.type == .fishline })
        let point = entities.first(where: { $0.type == .hookPoint }) as? HookPointEntity

        // Add a caught fish to verify its cleanup
        let fish = FishEntity(name: "caught_fish", position: Position3D(0, 0, 0))
        if let group = point?.group {
            group.caughtFish = fish
            fish.caughtBy = group
            engine.entities.append(fish)
        }

        let oldIds = Set([hook?.id, line?.id, point?.id, fish.id].compactMap { $0 })
        #expect(engine.entities.count == 4)

        // Kill the hook - this should trigger the cleanup of the whole group (including fish)
        hook?.kill()

        // The Engine processes dead entities in updateEntities
        engine.tickOnceForTests()

        // None of the old entities (including fish) should be in the engine anymore
        let remainingIds = Set(engine.entities.map { $0.id })
        #expect(oldIds.isDisjoint(with: remainingIds))

        // engine.spawnRandomObject() was called, so some new entity/entities should exist
        #expect(engine.entities.count >= 1)
    }

    @Test func testFractionalSynchronization() async throws {
        let group = FishingGroup()
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 0, 0))
        let line = FishlineEntity(name: "line", position: Position3D(16, -100, 0))

        hook.group = group
        line.group = group

        // Scenario: group.y moves to 1.9
        group.y = 1.9

        // With floor rounding:
        // hook.moveEntity returns floor(1.9) = 1
        // line.moveEntity returns floor(1.9 - 100) = floor(-98.1) = -99
        // Relative distance: 1 - (-99) = 100. Correct.

        // Without floor rounding (using Int truncation):
        // hook.moveEntity would return Int(1.9) = 1
        // line.moveEntity would return Int(-98.1) = -98
        // Relative distance: 1 - (-98) = 99. INCORRECT!

        let hookPos = hook.moveEntity(deltaTime: 0)
        let linePos = line.moveEntity(deltaTime: 0)

        #expect(hookPos?.y == 1)
        #expect(linePos?.y == -99)
        #expect((hookPos?.y ?? 0) - (linePos?.y ?? 0) == 100)
    }
}
