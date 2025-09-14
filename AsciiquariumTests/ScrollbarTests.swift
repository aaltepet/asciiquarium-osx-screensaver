//
//  ScrollbarTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

struct ScrollbarTests {

    // MARK: - Test Helper Functions

    private func createTestRenderer() -> ASCIIRenderer {
        return ASCIIRenderer()
    }

    private func createTestEngine() -> AsciiquariumEngine {
        return AsciiquariumEngine()
    }

    private func createTestEntities() -> [AquariumEntity] {
        return [
            AquariumEntity(
                type: .fish, position: CGPoint(x: 100, y: 100), shape: "><>", color: .blue,
                speed: 1.0),
            AquariumEntity(
                type: .fish, position: CGPoint(x: 200, y: 150), shape: "><>", color: .cyan,
                speed: 1.0),
            AquariumEntity(
                type: .fish, position: CGPoint(x: 300, y: 200), shape: "><>", color: .green,
                speed: 1.0),
        ]
    }

    private func calculateContentDimensions(attributedString: NSAttributedString, font: NSFont) -> (
        width: CGFloat, height: CGFloat
    ) {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage(attributedString: attributedString)

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        // Configure text container to measure content
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = 0
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false

        // Set a very large size to measure actual content
        textContainer.size = CGSize(width: 10000, height: 10000)

        // Force layout
        layoutManager.ensureLayout(for: textContainer)

        // Get the actual used rect
        let usedRect = layoutManager.usedRect(for: textContainer)

        return (usedRect.width, usedRect.height)
    }

    // MARK: - Scrollbar Prevention Tests

    @Test func testOptimalGridCalculationFitsPerfectly() async throws {
        let renderer = createTestRenderer()
        let testBounds = [
            CGRect(x: 0, y: 0, width: 400, height: 300),  // Small screen
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium screen
            CGRect(x: 0, y: 0, width: 1200, height: 800),  // Large screen
            CGRect(x: 0, y: 0, width: 1920, height: 1080),  // HD screen
        ]

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
            let charWidth = calculateCharacterWidth(for: font)
            let lineHeight = calculateLineHeight(for: font)

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
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

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
        let contentDimensions = calculateContentDimensions(
            attributedString: attributedString, font: font)

        // Calculate expected dimensions based on grid
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)
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
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

        let aspectRatios = [
            (width: 400.0, height: 300.0),  // 4:3
            (width: 800.0, height: 450.0),  // 16:9
            (width: 1200.0, height: 400.0),  // 3:1 (very wide)
            (width: 400.0, height: 1200.0),  // 1:3 (very tall)
            (width: 600.0, height: 600.0),  // 1:1 (square)
        ]

        for (width, height) in aspectRatios {
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
            let contentDimensions = calculateContentDimensions(
                attributedString: attributedString, font: font)

            // Content should fit within bounds (proving no scrollbar needed)
            let tolerance: CGFloat = 3.0
            #expect(
                contentDimensions.width <= bounds.width + tolerance,
                "Content should fit width for aspect ratio \(width):\(height). Content: \(contentDimensions.width), Bounds: \(bounds.width)"
            )
            #expect(
                contentDimensions.height <= bounds.height + tolerance,
                "Content should fit height for aspect ratio \(width):\(height). Content: \(contentDimensions.height), Bounds: \(bounds.height)"
            )
        }
    }

    @Test func testDynamicResizingMaintainsNoScrollbar() async throws {
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

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
            let contentDimensions = calculateContentDimensions(
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
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

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

    @Test func testFontSizeOptimization() async throws {
        let renderer = createTestRenderer()

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

    // MARK: - Helper Functions

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }
}
