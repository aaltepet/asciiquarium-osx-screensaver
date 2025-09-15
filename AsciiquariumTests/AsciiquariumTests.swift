//
//  AsciiquariumTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import CoreGraphics
import Testing

/// Main integration tests for the Asciiquarium application
struct AsciiquariumTests {

    // MARK: - Integration Tests

    @Test func testBasicApplicationFlow() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Test the complete flow: calculate optimal grid, update engine, render scene
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)
        engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

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
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Update engine with optimal dimensions
        engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

        // Render using engine's entities
        let attributedString = renderer.renderScene(
            entities: engine.entities, gridWidth: 80, gridHeight: 24)

        // Should render successfully
        #expect(!attributedString.string.isEmpty, "Should render engine entities")

        // Engine should have reasonable dimensions
        #expect(engine.gridWidth > 0, "Engine should have positive grid width")
        #expect(engine.gridHeight > 0, "Engine should have positive grid height")
    }

    @Test func testFontMetricsIntegration() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Test FontMetrics integration
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Should produce valid results
        #expect(optimalGrid.width > 0, "FontMetrics should produce positive width")
        #expect(optimalGrid.height > 0, "FontMetrics should produce positive height")
        #expect(optimalGrid.fontSize >= 8.0, "FontMetrics should produce reasonable font size")
        #expect(optimalGrid.fontSize <= 24.0, "FontMetrics should produce reasonable font size")

        // Test character calculations
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let charWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        let lineHeight = FontMetrics.shared.calculateLineHeight(for: font)

        #expect(charWidth > 0, "Character width should be positive")
        #expect(lineHeight > 0, "Line height should be positive")
    }

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

            // Calculate optimal grid
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Update engine
            engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

            // Render scene
            let attributedString = renderer.renderScene(
                entities: entities, gridWidth: 80, gridHeight: 24)

            // Should always produce valid output
            #expect(!attributedString.string.isEmpty, "Should render for size \(size)")
            #expect(
                attributedString.string.contains("~"),
                "Should contain water surface for size \(size)")
            #expect(
                attributedString.string.contains("="),
                "Should contain bottom border for size \(size)")
        }
    }

    @Test func testPerformanceUnderLoad() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

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
