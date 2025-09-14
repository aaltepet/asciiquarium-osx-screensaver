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

        for bounds in testBounds {
            let attributedString = renderer.renderScene(entities: entities, in: bounds)

            // Should render successfully for all bounds
            #expect(!attributedString.string.isEmpty, "Should render for bounds: \(bounds)")

            // Should contain expected elements
            #expect(
                attributedString.string.contains("~"),
                "Should contain water surface for bounds: \(bounds)")
            #expect(
                attributedString.string.contains("="),
                "Should contain bottom border for bounds: \(bounds)")
        }
    }

    @Test func testWaterSurfaceAndBottomBorder() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let attributedString = renderer.renderScene(entities: entities, in: bounds)
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

        // Update font with larger size
        renderer.updateFont(size: 16.0)

        // Character dimensions should change
        #expect(
            renderer.characterWidth != originalCharacterWidth,
            "Character width should change with font size")
        #expect(
            renderer.lineHeight != originalLineHeight, "Line height should change with font size")
    }

    @Test func testFontUpdateWithOptimalSizing() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Update font with optimal sizing
        renderer.updateFontWithOptimalSizing(for: bounds)

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
        let attributedString = renderer.renderScene(entities: entities, in: bounds)
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
        let attributedString = renderer.renderScene(entities: entities, in: bounds)
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

    @Test func testOptimalGridCalculationFitsPerfectly() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let testBounds = TestHelpers.generateTestBounds()

        for bounds in testBounds {
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Grid dimensions should be positive
            #expect(optimalGrid.width > 0, "Grid width should be positive for bounds: \(bounds)")
            #expect(optimalGrid.height > 0, "Grid height should be positive for bounds: \(bounds)")

            // Font size should be reasonable
            #expect(
                optimalGrid.fontSize >= 8.0,
                "Font size should be at least 8pt for bounds: \(bounds)")
            #expect(
                optimalGrid.fontSize <= 24.0,
                "Font size should be at most 24pt for bounds: \(bounds)")

            // Calculate actual pixel dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let charWidth = TestHelpers.calculateCharacterWidth(for: font)
            let lineHeight = TestHelpers.calculateLineHeight(for: font)

            let actualWidth = CGFloat(optimalGrid.width) * charWidth
            let actualHeight = CGFloat(optimalGrid.height) * lineHeight

            // Content should fit within bounds (with small tolerance for rounding)
            let tolerance: CGFloat = 2.0
            #expect(
                actualWidth <= bounds.width + tolerance,
                "Content width should fit within bounds. Actual: \(actualWidth), Bounds: \(bounds.width)"
            )
            #expect(
                actualHeight <= bounds.height + tolerance,
                "Content height should fit within bounds. Actual: \(actualHeight), Bounds: \(bounds.height)"
            )

            // Content should use most of the available space (at least 80%)
            let widthUtilization = actualWidth / bounds.width
            let heightUtilization = actualHeight / bounds.height
            #expect(
                widthUtilization >= 0.8,
                "Should use at least 80% of available width. Utilization: \(widthUtilization)")
            #expect(
                heightUtilization >= 0.8,
                "Should use at least 80% of available height. Utilization: \(heightUtilization)")
        }
    }

    @Test func testRenderedContentMatchesCalculatedDimensions() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let testBounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: testBounds)

        // Update engine with optimal dimensions
        engine.updateSceneDimensions(
            width: optimalGrid.width,
            height: optimalGrid.height,
            fontSize: optimalGrid.fontSize
        )

        // Render the scene
        let attributedString = renderer.renderScene(entities: entities, in: testBounds)

        // Calculate actual content dimensions
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let contentDimensions = TestHelpers.calculateAttributedStringSize(
            attributedString: attributedString, font: font)

        // Calculate expected dimensions based on grid
        let charWidth = TestHelpers.calculateCharacterWidth(for: font)
        let lineHeight = TestHelpers.calculateLineHeight(for: font)
        let expectedWidth = CGFloat(optimalGrid.width) * charWidth
        let expectedHeight = CGFloat(optimalGrid.height) * lineHeight

        // Content dimensions should match expected dimensions (within tolerance)
        let tolerance: CGFloat = 5.0
        #expect(
            abs(contentDimensions.width - expectedWidth) <= tolerance,
            "Content width should match expected width. Actual: \(contentDimensions.width), Expected: \(expectedWidth)"
        )
        #expect(
            abs(contentDimensions.height - expectedHeight) <= tolerance,
            "Content height should match expected height. Actual: \(contentDimensions.height), Expected: \(expectedHeight)"
        )
    }

    @Test func testNoScrollbarWithDifferentAspectRatios() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let aspectRatios = TestHelpers.generateAspectRatioBounds()

        for (width, height, name) in aspectRatios {
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)

            // Calculate optimal grid
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Update engine
            engine.updateSceneDimensions(
                width: optimalGrid.width,
                height: optimalGrid.height,
                fontSize: optimalGrid.fontSize
            )

            // Render scene
            let attributedString = renderer.renderScene(entities: entities, in: bounds)

            // Calculate actual content dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let contentDimensions = TestHelpers.calculateAttributedStringSize(
                attributedString: attributedString, font: font)

            // Content should fit within bounds (proving no scrollbar needed)
            let tolerance: CGFloat = 3.0
            #expect(
                contentDimensions.width <= bounds.width + tolerance,
                "Content should fit width for aspect ratio \(name). Content: \(contentDimensions.width), Bounds: \(bounds.width)"
            )
            #expect(
                contentDimensions.height <= bounds.height + tolerance,
                "Content should fit height for aspect ratio \(name). Content: \(contentDimensions.height), Bounds: \(bounds.height)"
            )
        }
    }

    @Test func testDynamicResizingMaintainsNoScrollbar() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        // Test multiple resize scenarios
        let resizeScenarios = [
            CGRect(x: 0, y: 0, width: 400, height: 300),
            CGRect(x: 0, y: 0, width: 600, height: 400),
            CGRect(x: 0, y: 0, width: 800, height: 600),
            CGRect(x: 0, y: 0, width: 1000, height: 700),
            CGRect(x: 0, y: 0, width: 1200, height: 800),
        ]

        for bounds in resizeScenarios {
            // Calculate optimal grid for this size
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Update engine
            engine.updateSceneDimensions(
                width: optimalGrid.width,
                height: optimalGrid.height,
                fontSize: optimalGrid.fontSize
            )

            // Render scene
            let attributedString = renderer.renderScene(entities: entities, in: bounds)

            // Verify content fits perfectly
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let contentDimensions = TestHelpers.calculateAttributedStringSize(
                attributedString: attributedString, font: font)

            // Content should always fit within bounds
            let tolerance: CGFloat = 2.0
            #expect(
                contentDimensions.width <= bounds.width + tolerance,
                "Content should fit after resize to \(bounds.size). Content: \(contentDimensions.width), Bounds: \(bounds.width)"
            )
            #expect(
                contentDimensions.height <= bounds.height + tolerance,
                "Content should fit after resize to \(bounds.size). Content: \(contentDimensions.height), Bounds: \(bounds.height)"
            )
        }
    }

    @Test func testCharacterGridIntegrity() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)
        engine.updateSceneDimensions(
            width: optimalGrid.width,
            height: optimalGrid.height,
            fontSize: optimalGrid.fontSize
        )

        // Render scene
        let attributedString = renderer.renderScene(entities: entities, in: bounds)
        let lines = attributedString.string.components(separatedBy: "\n")

        // All lines should have the same width (monospaced grid)
        let expectedLineWidth = optimalGrid.width
        for (index, line) in lines.enumerated() {
            if !line.isEmpty {  // Skip empty lines
                #expect(
                    line.count == expectedLineWidth,
                    "Line \(index) should have width \(expectedLineWidth), but has \(line.count)")
            }
        }

        // Should have the expected number of lines
        let expectedLineCount = optimalGrid.height
        #expect(
            lines.count >= expectedLineCount,
            "Should have at least \(expectedLineCount) lines, but has \(lines.count)")
    }

    // MARK: - Edge Case Tests

    @Test func testEdgeCasesPreventScrollbar() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let engine = TestHelpers.createTestEngine()
        let entities = TestHelpers.createTestEntities()

        let edgeCases = TestHelpers.generateEdgeCaseBounds()

        for bounds in edgeCases {
            // Calculate optimal grid
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Update engine
            engine.updateSceneDimensions(
                width: optimalGrid.width,
                height: optimalGrid.height,
                fontSize: optimalGrid.fontSize
            )

            // Render scene
            let attributedString = renderer.renderScene(entities: entities, in: bounds)

            // Calculate actual content dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let contentDimensions = TestHelpers.calculateAttributedStringSize(
                attributedString: attributedString, font: font)

            // Even with edge cases, content should fit within bounds
            let tolerance: CGFloat = 5.0  // Larger tolerance for edge cases
            #expect(
                contentDimensions.width <= bounds.width + tolerance,
                "Content should fit width for edge case \(bounds.size). Content: \(contentDimensions.width), Bounds: \(bounds.width)"
            )
            #expect(
                contentDimensions.height <= bounds.height + tolerance,
                "Content should fit height for edge case \(bounds.size). Content: \(contentDimensions.height), Bounds: \(bounds.height)"
            )

            // Grid dimensions should be reasonable
            #expect(
                optimalGrid.width > 0, "Grid width should be positive for edge case \(bounds.size)")
            #expect(
                optimalGrid.height > 0,
                "Grid height should be positive for edge case \(bounds.size)")
        }
    }

    @Test func testFontSizeOptimization() async throws {
        let renderer = TestHelpers.createTestRenderer()

        let testBounds = [
            CGRect(x: 0, y: 0, width: 200, height: 150),  // Very small
            CGRect(x: 0, y: 0, width: 400, height: 300),  // Small
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium
            CGRect(x: 0, y: 0, width: 1600, height: 1200),  // Large
        ]

        var previousFontSize: CGFloat = 0

        for bounds in testBounds {
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Font size should increase with larger bounds
            if previousFontSize > 0 {
                #expect(
                    optimalGrid.fontSize >= previousFontSize,
                    "Font size should generally increase with larger bounds. Previous: \(previousFontSize), Current: \(optimalGrid.fontSize)"
                )
            }

            // Font size should be reasonable
            #expect(optimalGrid.fontSize >= 8.0, "Font size should be at least 8pt")
            #expect(optimalGrid.fontSize <= 24.0, "Font size should be at most 24pt")

            previousFontSize = optimalGrid.fontSize
        }
    }

    // MARK: - Performance Tests

    @Test func testRenderingPerformance() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Measure time for multiple renders
        let (_, executionTime) = TestHelpers.measureExecutionTime {
            for _ in 0..<10 {
                _ = renderer.renderScene(entities: entities, in: bounds)
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
        let result1 = renderer.renderScene(entities: entities, in: bounds)
        let result2 = renderer.renderScene(entities: entities, in: bounds)

        // Results should be identical
        #expect(
            result1.string == result2.string, "Rendering should be consistent across multiple calls"
        )
    }
}
