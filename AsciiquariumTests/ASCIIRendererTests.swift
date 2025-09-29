//
//  ASCIIRendererTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import CoreGraphics
import Testing

/// Comprehensive tests for ASCIIRenderer functionality
struct ASCIIRendererTests {

    // MARK: - Basic Rendering Tests

    @Test func testAttributedStringCreation() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let attributedString = renderer.drawCharacter("A", at: CGPoint(x: 0, y: 0), color: .blue)

        // Should return a non-empty attributed string
        #expect(!attributedString.string.isEmpty, "Attributed string should not be empty")
        #expect(attributedString.string == "A", "Should contain correct character")
    }

    @Test func testAttributedStringAttributes() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let attributedString = renderer.drawCharacter("Test", at: CGPoint(x: 0, y: 0), color: .blue)
        var range = NSRange(location: 0, length: attributedString.length)
        let attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        // Should have font attribute
        #expect(attributes[NSAttributedString.Key.font] != nil, "Should have font attribute")

        // Should have color attribute
        #expect(
            attributes[NSAttributedString.Key.foregroundColor] != nil, "Should have color attribute"
        )

        // Color should be blue
        if let color = attributes[NSAttributedString.Key.foregroundColor] as? NSColor {
            #expect(color == NSColor.blue, "Should have blue color")
        }
    }

    @Test func testSceneRenderingWithDifferentBounds() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let testBounds = TestHelpers.generateTestBounds()

        for _ in testBounds {  // bounds no longer impact font/grid in renderer
            let attributedString = renderer.renderScene(
                entities: entities, gridWidth: 80, gridHeight: 24)

            #expect(!attributedString.string.isEmpty, "Should render scene")
            #expect(attributedString.string.contains("~"), "Should contain water surface")
            #expect(attributedString.string.contains("="), "Should contain bottom border")
        }
    }

    @Test func testWaterSurfaceAndBottomBorder() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

        // Should have water surface
        var hasWaterSurface = false
        for line in lines {
            if line.contains("~") {
                hasWaterSurface = true
                break
            }
        }

        #expect(hasWaterSurface, "Should have water surface line")

        // Should have bottom border
        var hasBottomBorder = false
        for line in lines {
            if line.contains("=") {
                hasBottomBorder = true
                break
            }
        }
        #expect(hasBottomBorder, "Should have bottom border line")
    }

    // MARK: - Font Management Tests

    @Test func testFontUpdateWithSize() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let originalCharacterWidth = renderer.characterWidth
        let originalLineHeight = renderer.lineHeight

        // Update font to same fixed size should keep dimensions identical
        renderer.updateFont(size: FontMetrics.shared.getDefaultFontSize())

        #expect(renderer.characterWidth == originalCharacterWidth)
        #expect(renderer.lineHeight == originalLineHeight)
    }

    @Test func testFontUpdateWithOptimalSizing() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Update font with optimal sizing
        renderer.updateFont(size: 12.0)

        // Font should be updated (we can't easily test the exact size without FontMetrics access)
        #expect(
            renderer.characterWidth > 0, "Character width should be positive after optimal sizing")
        #expect(renderer.lineHeight > 0, "Line height should be positive after optimal sizing")
    }

    @Test func testCharacterDimensionsConsistency() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Get dimensions multiple times
        let width1 = renderer.characterWidth
        let height1 = renderer.lineHeight
        let width2 = renderer.characterWidth
        let height2 = renderer.lineHeight

        // Should be consistent
        #expect(width1 == width2, "Character width should be consistent")
        #expect(height1 == height2, "Line height should be consistent")
    }

    // MARK: - Character Positioning Tests

    @Test func testCharacterPositioning() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

        // All lines should have the same width (monospaced)
        let expectedWidth = lines.first?.count ?? 0
        for line in lines {
            if !line.isEmpty {  // Skip empty lines
                #expect(line.count == expectedWidth, "All lines should have same width")
            }
        }
    }

    @Test func testSceneDimensions() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

        // Should have reasonable number of lines
        #expect(lines.count > 0, "Should have at least one line")
        #expect(lines.count < 100, "Should not have too many lines")

        // All lines should have reasonable width
        for line in lines {
            if !line.isEmpty {
                #expect(line.count > 0, "Lines should not be empty")
                #expect(line.count < 1000, "Lines should not be too wide")
            }
        }
    }

    // MARK: - Scrollbar Prevention Tests

    // Removed tests tied to old optimal grid calculation

    // Removed rendered size vs calculated dimensions test tied to optimization

    // Removed aspect ratio scrollbar tests tied to optimization

    // Removed dynamic resizing no-scrollbar test tied to optimization

    // Removed grid integrity test tied to optimization outputs

    // MARK: - Edge Case Tests

    // Removed edge case tests tied to optimization

    // Removed font size optimization behavioral test

    // MARK: - Performance Tests

    @Test func testRenderingPerformance() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Measure time for multiple renders
        let (_, executionTime) = TestHelpers.measureExecutionTime {
            for _ in 0..<10 {
                _ = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)
            }
        }

        // Should complete 10 renders in reasonable time (less than 1 second)
        #expect(
            executionTime < 1.0,
            "ASCIIRenderer should be performant. 10 renders took \(executionTime) seconds")
    }

    // MARK: - Consistency Tests

    @Test func testRenderingConsistency() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Render the same scene multiple times
        let result1 = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)
        let result2 = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)

        // Results should be identical
        #expect(
            result1.string == result2.string, "Rendering should be consistent across multiple calls"
        )
    }

    // MARK: - Single Entity Placement Tests

    @Test func testWaterlineEntityPlacement() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let gridWidth = 80
        let gridHeight = 24

        // Create a single waterline entity at a specific position
        let waterlinePosition = Position3D(0, 4, 0)  // x=0 (full-width), y=4 (grid row), z=0
        let waterline = EntityFactory.createWaterline(at: waterlinePosition, segmentIndex: 0)
        let entities = [waterline]

        // Get the cached waterline pattern directly
        let cachedWaterline = waterline.getShape(for: gridWidth)

        // Render the scene using grid coordinates
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: gridWidth, gridHeight: gridHeight)
        let lines = attributedString.string.components(separatedBy: "\n")

        // Waterline should be at grid row 4
        let expectedGridY = waterlinePosition.y

        // Verify the waterline appears at the correct position
        #expect(expectedGridY < lines.count, "Waterline should be within bounds")

        if expectedGridY < lines.count {
            let waterlineLine = lines[expectedGridY]

            // Verify waterline spans the full width
            #expect(waterlineLine.count >= gridWidth, "Waterline should span full width")

            // Verify the waterline matches the cached pattern
            #expect(
                waterlineLine == cachedWaterline[0],
                "Rendered waterline should match cached pattern")

            // Verify it contains valid waterline characters (waves or carets)
            let hasValidChars = waterlineLine.contains("~") || waterlineLine.contains("^")
            #expect(hasValidChars, "Waterline should contain wave or caret characters")
        }
    }

}
