//
//  HybridApproachTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

struct HybridApproachTests {

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

    // MARK: - Hybrid Approach Core Tests

    @Test func testOptimalGridCalculationAlgorithm() async throws {
        let renderer = createTestRenderer()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        let optimalGrid = renderer.calculateOptimalGridDimensions(for: bounds)

        // Verify the algorithm found a valid solution
        #expect(optimalGrid.width > 0, "Optimal grid width should be positive")
        #expect(optimalGrid.height > 0, "Optimal grid height should be positive")
        #expect(optimalGrid.fontSize >= 8.0, "Font size should be at least 8pt")
        #expect(optimalGrid.fontSize <= 24.0, "Font size should be at most 24pt")

        // Verify the solution is actually optimal by testing nearby font sizes
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        let currentFit = calculateFitScore(
            gridWidth: optimalGrid.width,
            gridHeight: optimalGrid.height,
            charWidth: charWidth,
            lineHeight: lineHeight,
            bounds: bounds
        )

        // Test slightly larger font size
        let largerFont = NSFont.monospacedSystemFont(
            ofSize: optimalGrid.fontSize + 0.5, weight: .regular)
        let largerCharWidth = calculateCharacterWidth(for: largerFont)
        let largerLineHeight = calculateLineHeight(for: largerFont)
        let largerGridWidth = Int(bounds.width / largerCharWidth)
        let largerGridHeight = Int(bounds.height / largerLineHeight)

        if largerGridWidth > 0 && largerGridHeight > 0 {
            let largerFit = calculateFitScore(
                gridWidth: largerGridWidth,
                gridHeight: largerGridHeight,
                charWidth: largerCharWidth,
                lineHeight: largerLineHeight,
                bounds: bounds
            )
            #expect(
                currentFit >= largerFit,
                "Current solution should be at least as good as larger font size")
        }

        // Test slightly smaller font size
        let smallerFont = NSFont.monospacedSystemFont(
            ofSize: max(8.0, optimalGrid.fontSize - 0.5), weight: .regular)
        let smallerCharWidth = calculateCharacterWidth(for: smallerFont)
        let smallerLineHeight = calculateLineHeight(for: smallerFont)
        let smallerGridWidth = Int(bounds.width / smallerCharWidth)
        let smallerGridHeight = Int(bounds.height / smallerLineHeight)

        if smallerGridWidth > 0 && smallerGridHeight > 0 {
            let smallerFit = calculateFitScore(
                gridWidth: smallerGridWidth,
                gridHeight: smallerGridHeight,
                charWidth: smallerCharWidth,
                lineHeight: smallerLineHeight,
                bounds: bounds
            )
            #expect(
                currentFit >= smallerFit,
                "Current solution should be at least as good as smaller font size")
        }
    }

    @Test func testDynamicSceneDimensionsUpdate() async throws {
        let engine = createTestEngine()
        let renderer = createTestRenderer()

        let testBounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let optimalGrid = renderer.calculateOptimalGridDimensions(for: testBounds)

        // Update engine with new dimensions
        engine.updateSceneDimensions(
            width: optimalGrid.width,
            height: optimalGrid.height,
            fontSize: optimalGrid.fontSize
        )

        // Verify engine dimensions were updated correctly
        #expect(
            engine.gridWidth == optimalGrid.width,
            "Engine grid width should match optimal grid width")
        #expect(
            engine.gridHeight == optimalGrid.height,
            "Engine grid height should match optimal grid height")

        // Verify calculated scene dimensions
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let expectedWidth = CGFloat(optimalGrid.width) * calculateCharacterWidth(for: font)
        let expectedHeight = CGFloat(optimalGrid.height) * calculateLineHeight(for: font)

        let tolerance: CGFloat = 1.0
        #expect(
            abs(engine.sceneWidth - expectedWidth) <= tolerance,
            "Engine scene width should match calculated width. Engine: \(engine.sceneWidth), Expected: \(expectedWidth)"
        )
        #expect(
            abs(engine.sceneHeight - expectedHeight) <= tolerance,
            "Engine scene height should match calculated height. Engine: \(engine.sceneHeight), Expected: \(expectedHeight)"
        )
    }

    @Test func testPerfectContentFit() async throws {
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

        let testBounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid
        let optimalGrid = renderer.calculateOptimalGridDimensions(for: testBounds)

        // Update engine
        engine.updateSceneDimensions(
            width: optimalGrid.width,
            height: optimalGrid.height,
            fontSize: optimalGrid.fontSize
        )

        // Render scene
        let attributedString = renderer.renderScene(entities: entities, in: testBounds)

        // Calculate actual content dimensions
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let contentSize = calculateAttributedStringSize(
            attributedString: attributedString, font: font)

        // Content should fit perfectly within the calculated scene dimensions
        let tolerance: CGFloat = 2.0
        #expect(
            contentSize.width <= engine.sceneWidth + tolerance,
            "Content width should fit within scene width. Content: \(contentSize.width), Scene: \(engine.sceneWidth)"
        )
        #expect(
            contentSize.height <= engine.sceneHeight + tolerance,
            "Content height should fit within scene height. Content: \(contentSize.height), Scene: \(engine.sceneHeight)"
        )

        // Content should use most of the available space
        let widthUtilization = contentSize.width / engine.sceneWidth
        let heightUtilization = contentSize.height / engine.sceneHeight
        #expect(
            widthUtilization >= 0.9,
            "Content should use at least 90% of scene width. Utilization: \(widthUtilization)")
        #expect(
            heightUtilization >= 0.9,
            "Content should use at least 90% of scene height. Utilization: \(heightUtilization)")
    }

    @Test func testHybridApproachScalability() async throws {
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

        let testSizes = [
            CGSize(width: 400, height: 300),  // Small
            CGSize(width: 800, height: 600),  // Medium
            CGSize(width: 1200, height: 800),  // Large
            CGSize(width: 1920, height: 1080),  // HD
            CGSize(width: 2560, height: 1440),  // 2K
        ]

        for size in testSizes {
            let bounds = CGRect(origin: .zero, size: size)

            // Calculate optimal grid
            let optimalGrid = renderer.calculateOptimalGridDimensions(for: bounds)

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
            let contentSize = calculateAttributedStringSize(
                attributedString: attributedString, font: font)

            let tolerance: CGFloat = 3.0
            #expect(
                contentSize.width <= engine.sceneWidth + tolerance,
                "Content should fit width for size \(size). Content: \(contentSize.width), Scene: \(engine.sceneWidth)"
            )
            #expect(
                contentSize.height <= engine.sceneHeight + tolerance,
                "Content should fit height for size \(size). Content: \(contentSize.height), Scene: \(engine.sceneHeight)"
            )

            // Verify reasonable utilization
            let widthUtilization = contentSize.width / engine.sceneWidth
            let heightUtilization = contentSize.height / engine.sceneHeight
            #expect(
                widthUtilization >= 0.8, "Should use at least 80% of scene width for size \(size)")
            #expect(
                heightUtilization >= 0.8, "Should use at least 80% of scene height for size \(size)"
            )
        }
    }

    @Test func testHybridApproachConsistency() async throws {
        let renderer = createTestRenderer()
        let engine = createTestEngine()
        let entities = createTestEntities()

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Run the hybrid approach multiple times with the same input
        var results:
            [(
                gridWidth: Int, gridHeight: Int, fontSize: CGFloat, sceneWidth: CGFloat,
                sceneHeight: CGFloat
            )] = []

        for _ in 0..<5 {
            let optimalGrid = renderer.calculateOptimalGridDimensions(for: bounds)
            engine.updateSceneDimensions(
                width: optimalGrid.width,
                height: optimalGrid.height,
                fontSize: optimalGrid.fontSize
            )

            results.append(
                (
                    gridWidth: optimalGrid.width,
                    gridHeight: optimalGrid.height,
                    fontSize: optimalGrid.fontSize,
                    sceneWidth: engine.sceneWidth,
                    sceneHeight: engine.sceneHeight
                ))
        }

        // All results should be identical
        let firstResult = results[0]
        for (index, result) in results.enumerated() {
            #expect(
                result.gridWidth == firstResult.gridWidth,
                "Grid width should be consistent across runs. Run \(index): \(result.gridWidth), First: \(firstResult.gridWidth)"
            )
            #expect(
                result.gridHeight == firstResult.gridHeight,
                "Grid height should be consistent across runs. Run \(index): \(result.gridHeight), First: \(firstResult.gridHeight)"
            )
            #expect(
                result.fontSize == firstResult.fontSize,
                "Font size should be consistent across runs. Run \(index): \(result.fontSize), First: \(firstResult.fontSize)"
            )
            #expect(
                result.sceneWidth == firstResult.sceneWidth,
                "Scene width should be consistent across runs. Run \(index): \(result.sceneWidth), First: \(firstResult.sceneWidth)"
            )
            #expect(
                result.sceneHeight == firstResult.sceneHeight,
                "Scene height should be consistent across runs. Run \(index): \(result.sceneHeight), First: \(firstResult.sceneHeight)"
            )
        }
    }

    // MARK: - Helper Functions

    private func calculateFitScore(
        gridWidth: Int, gridHeight: Int, charWidth: CGFloat, lineHeight: CGFloat, bounds: CGRect
    ) -> Double {
        let usedWidth = CGFloat(gridWidth) * charWidth
        let usedHeight = CGFloat(gridHeight) * lineHeight
        let totalArea = bounds.width * bounds.height
        let usedArea = usedWidth * usedHeight
        return usedArea / totalArea
    }

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    private func calculateAttributedStringSize(attributedString: NSAttributedString, font: NSFont)
        -> CGSize
    {
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

        return usedRect.size
    }
}
