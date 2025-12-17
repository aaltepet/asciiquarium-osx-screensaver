//
//  AsciiquariumTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import CoreGraphics
import Testing

@testable import AsciiquariumCore

/// Main integration tests for the Asciiquarium application
struct AsciiquariumTests {

    // MARK: - Integration Tests

    @Test func testBasicApplicationFlow() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Test the complete flow with fixed font size grid
        let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
        let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
        let dims = FontMetrics.shared.calculateGridDimensions(for: bounds, font: fixedFont)
        engine.updateGridDimensions(width: dims.width, height: dims.height)

        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)

        // Basic validation that the flow works
        #expect(!attributedString.string.isEmpty, "Should produce non-empty output")
        #expect(attributedString.string.contains("~"), "Should contain water surface")
        #expect(attributedString.string.contains("="), "Should contain bottom border")
    }

    @Test func testEngineRendererIntegration() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
        let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
        let dims = FontMetrics.shared.calculateGridDimensions(for: bounds, font: fixedFont)

        // Update engine with fixed-dimension grid
        engine.updateGridDimensions(width: dims.width, height: dims.height)

        // Render using engine's entities
        let attributedString = renderer.renderScene(
            entities: engine.entities, gridWidth: 80, gridHeight: 24)

        // Should render successfully
        #expect(!attributedString.string.isEmpty, "Should render engine entities")

        // Engine should have reasonable dimensions
        #expect(engine.gridWidth > 0, "Engine should have positive grid width")
        #expect(engine.gridHeight > 0, "Engine should have positive grid height")
    }

    // Removed old FontMetrics integration test focused on optimization

    @Test func testMultipleResizeScenarios() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let resizeScenarios = [
            CGSize(width: 400, height: 300),
            CGSize(width: 800, height: 600),
            CGSize(width: 1200, height: 800),
            CGSize(width: 600, height: 400),  // Resize back down
        ]

        for size in resizeScenarios {
            let bounds = CGRect(origin: .zero, size: size)

            // Calculate grid using fixed font
            let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
            let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
            let dims = FontMetrics.shared.calculateGridDimensions(for: bounds, font: fixedFont)

            // Update engine
            engine.updateGridDimensions(width: dims.width, height: dims.height)

            // Render scene
            let attributedString = renderer.renderScene(
                entities: entities, gridWidth: dims.width, gridHeight: dims.height)

            // Should always produce valid output
            #expect(!attributedString.string.isEmpty, "Should render for size \(size)")
            #expect(attributedString.string.contains("~"))
            #expect(attributedString.string.contains("="))
        }
    }

    @Test func testPerformanceUnderLoad() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
        let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
        let dims = FontMetrics.shared.calculateGridDimensions(for: bounds, font: fixedFont)

        engine.updateGridDimensions(width: dims.width, height: dims.height)

        // Measure performance of multiple renders
        let (_, executionTime) = TestHelpers.measureExecutionTime {
            for _ in 0..<50 {
                _ = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)
            }
        }

        // Should complete 50 renders in reasonable time (less than 2 seconds)
        #expect(
            executionTime < 2.0,
            "Should handle 50 renders efficiently. Took \(executionTime) seconds")
    }
}
