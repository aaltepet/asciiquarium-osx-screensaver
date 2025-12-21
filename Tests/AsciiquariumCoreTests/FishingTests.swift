import Foundation
import Testing

@testable import AsciiquariumCore

@Suite("Fishing Movement Tests")
struct FishingTests {

    @Test func testFishingGroupSynchronization() async throws {
        let group = FishingGroup()
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 0, 0))
        let line = FishlineEntity(name: "line", position: Position3D(17, -100, 0))
        let point = HookPointEntity(name: "point", position: Position3D(11, 2, 0))

        hook.group = group
        line.group = group
        point.group = group

        // Initial state: descending
        #expect(group.state == .descending)

        // Move one tick (1/30 sec)
        let deltaTime: TimeInterval = 1.0 / 30.0

        let newHookPos = hook.moveEntity(deltaTime: deltaTime)
        let newLinePos = line.moveEntity(deltaTime: deltaTime)
        let newPointPos = point.moveEntity(deltaTime: deltaTime)

        // All should move down by 1 cell (speed 1.0 * 30 FPS * 1/30 sec = 1 cell)
        #expect(newHookPos?.y == 1)
        #expect(newLinePos?.y == -99)
        #expect(newPointPos?.y == 3)

        // Switch to retracting
        group.retract()
        #expect(group.state == .retracting)

        // Move another tick
        let retractHookPos = hook.moveEntity(deltaTime: deltaTime)
        let retractLinePos = line.moveEntity(deltaTime: deltaTime)
        let retractPointPos = point.moveEntity(deltaTime: deltaTime)

        // Verify synchronized upward movement (retracting state)
        // Note: moveEntity returns the projected next position based on the current position without mutating it.
        #expect(retractHookPos?.y == -1)
        #expect(retractLinePos?.y == -101)
        #expect(retractPointPos?.y == 1)
    }

    @Test func testMaxDepthLogic() async throws {
        let group = FishingGroup()
        let gridHeight = 24

        // Place hook near max depth
        // Hook height is 6. If bottom (y + 6) is at 18, y = 12.
        let hook = FishhookEntity(name: "hook", position: Position3D(10, 11, 0))
        hook.group = group
        hook.gridHeight = gridHeight

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
        // Line height is 100. Line bottom should stop at 12.
        // Line top should be at 12 - 100 = -88.

        let line = FishlineEntity(name: "line", position: Position3D(10, -89, 0))
        line.group = group
        line.gridHeight = gridHeight

        let deltaTime: TimeInterval = 1.0 / 30.0

        let newPos = line.moveEntity(deltaTime: deltaTime)
        #expect(newPos?.y == -88)  // Bottom at -88 + 100 = 12.

        line.position = newPos!
        let newPos2 = line.moveEntity(deltaTime: deltaTime)
        #expect(newPos2?.y == -88)  // Should stay clamped
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

        let hook = engine.entities.first(where: { $0.type == .fishhook })
        let oldHookId = hook?.id
        #expect(engine.entities.count == 3)

        // Kill the hook - this should trigger the cleanup of the whole group
        hook?.kill()

        // The Engine processes dead entities in updateEntities
        engine.tickOnceForTests()

        // The old hook should be gone
        #expect(engine.entities.filter({ $0.id == oldHookId }).isEmpty)

        // Note: engine.spawnRandomObject() is called in deathCallback,
        // which currently always spawns a new hook. So there will be 3 entities again,
        // but they should be new ones.
        #expect(engine.entities.count == 3)
        #expect(engine.entities.first(where: { $0.type == .fishhook })?.id != oldHookId)
    }
}
