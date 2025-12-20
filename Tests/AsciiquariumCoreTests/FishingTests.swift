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
}
