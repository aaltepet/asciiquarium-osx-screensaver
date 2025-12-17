//
//  WaterlineTests.swift
//  AsciiquariumTests
//
//  Created by Test on 9/19/25.
//

import Testing

@testable import AsciiquariumCore

struct WaterlineTests {

    @Test func testWaterlineFixedTilingAndImmutability() async throws {
        // Given
        let gridWidth = 120
        let position = Position3D(0, 5, Depth.waterLine3)
        let waterline = EntityFactory.createWaterline(at: position, segmentIndex: 0)

        // When
        let shape1 = waterline.getShape(for: gridWidth)
        // Simulate a few update frames
        for _ in 0..<5 { waterline.update(deltaTime: 1.0 / 30.0) }
        let shape2 = waterline.getShape(for: gridWidth)

        // Then: exactly one line and full width tiling
        #expect(shape1.count == 1, "Waterline should be a single row")
        #expect(shape1[0].count == gridWidth, "Waterline should tile to full grid width")
        // Should be identical across frames (no animation)
        #expect(shape1 == shape2, "Waterline shape should not change across frames")
    }
}
