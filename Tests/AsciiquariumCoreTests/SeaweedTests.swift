//
//  SeaweedTests.swift
//  AsciiquariumTests
//
//  Created by Test on 9/23/25.
//

import Testing

@testable import AsciiquariumCore

struct SeaweedTests {
    @Test func testSeaweedSwaysWithVariableTiming() async throws {
        // Given
        let pos = Position3D(10, 10, Depth.seaweed)
        let sea = EntityFactory.createSeaweed(at: pos)
        let initial = sea.shape
        #expect(initial.count >= 3 && initial.count <= 6)

        // When: advance 14 frames (no sway expected - interval is 17-20 frames based on animSpeed)
        for _ in 0..<14 { sea.update(deltaTime: 1.0 / 30.0) }
        let shapeNoSway = sea.shape
        #expect(shapeNoSway == initial, "Seaweed should not sway too early")

        // Advance to at least 20 frames: should have swayed by now (interval is max 20 frames)
        for _ in 0..<6 { sea.update(deltaTime: 1.0 / 30.0) }
        let swayed = sea.shape
        #expect(swayed.count == initial.count, "Swayed shape should maintain same height")
        #expect(
            swayed.allSatisfy { $0 == "(" || $0 == ")" }, "Swayed shape should only contain ( or )")

        // Advance another 20 frames: should sway again (new random pattern)
        for _ in 0..<20 { sea.update(deltaTime: 1.0 / 30.0) }
        let swayedAgain = sea.shape
        #expect(swayedAgain.count == initial.count, "Second sway should maintain same height")
        #expect(
            swayedAgain.allSatisfy { $0 == "(" || $0 == ")" },
            "Second sway should only contain ( or )")
    }
}
