import AppKit
import Foundation
import Testing

/// Tests to prove width utilization issues and measure actual vs calculated space usage
struct WidthUtilizationTests {

    // MARK: - Helper Functions

    private func createTestRenderer() -> ASCIIRenderer {
        return ASCIIRenderer()
    }

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    private func calculateActualContentSize(
        renderer: ASCIIRenderer, entities: [AquariumEntity], bounds: CGRect
    ) -> CGSize {
        let attributedString = renderer.renderScene(entities: entities, in: bounds)

        // Calculate the actual size of the rendered content
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(
            size: CGSize(
                width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)

        let usedRect = layoutManager.usedRect(for: textContainer)
        return usedRect.size
    }

    private func createTestEntities(for bounds: CGRect) -> [AquariumEntity] {
        // Create entities that fill the entire grid
        let renderer = createTestRenderer()
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        var entities: [AquariumEntity] = []

        // Fill every character position with a test entity
        for y in 0..<gridDimensions.height {
            for x in 0..<gridDimensions.width {
                let entity = AquariumEntity(
                    type: .fish,
                    position: CGPoint(x: CGFloat(x), y: CGFloat(y)),
                    shape: "X",
                    color: .blue,
                    speed: 1.0
                )
                entities.append(entity)
            }
        }

        return entities
    }

    // MARK: - Width Utilization Tests

    @Test func testWidthUtilizationIsMaximized() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let renderer = createTestRenderer()
        let entities = createTestEntities(for: bounds)

        // Calculate optimal grid dimensions
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Calculate actual content size
        let actualSize = calculateActualContentSize(
            renderer: renderer, entities: entities, bounds: bounds)

        // Calculate expected size based on character metrics
        let optimalFont = NSFont.monospacedSystemFont(
            ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)
        let lineHeight = calculateLineHeight(for: optimalFont)

        let expectedWidth = CGFloat(gridDimensions.width) * charWidth
        let expectedHeight = CGFloat(gridDimensions.height) * lineHeight

        // Calculate utilization percentages
        let widthUtilization = actualSize.width / bounds.width
        let heightUtilization = actualSize.height / bounds.height

        print("=== Width Utilization Test ===")
        print("Bounds: \(bounds)")
        print("Grid: \(gridDimensions.width) x \(gridDimensions.height)")
        print("Font Size: \(gridDimensions.fontSize)")
        print("Char Width: \(charWidth)")
        print("Line Height: \(lineHeight)")
        print("Expected Size: \(expectedWidth) x \(expectedHeight)")
        print("Actual Size: \(actualSize.width) x \(actualSize.height)")
        print("Width Utilization: \(widthUtilization * 100)%")
        print("Height Utilization: \(heightUtilization * 100)%")
        print("Unused Width: \(bounds.width - actualSize.width)")
        print("Unused Height: \(bounds.height - actualSize.height)")

        // The content should use at least 95% of available width
        #expect(
            widthUtilization >= 0.95,
            "Width utilization should be at least 95%. Actual: \(widthUtilization * 100)%")

        // The content should use at least 90% of available height
        #expect(
            heightUtilization >= 0.90,
            "Height utilization should be at least 90%. Actual: \(heightUtilization * 100)%")

        // There should be minimal unused space
        let unusedWidth = bounds.width - actualSize.width
        let unusedHeight = bounds.height - actualSize.height

        #expect(
            unusedWidth <= bounds.width * 0.05,
            "Unused width should be less than 5%. Actual: \(unusedWidth) pixels")
        #expect(
            unusedHeight <= bounds.height * 0.10,
            "Unused height should be less than 10%. Actual: \(unusedHeight) pixels")
    }

    @Test func testCharacterCountMatchesAvailableSpace() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let renderer = createTestRenderer()

        // Calculate optimal grid dimensions
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Calculate character metrics
        let optimalFont = NSFont.monospacedSystemFont(
            ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)
        let lineHeight = calculateLineHeight(for: optimalFont)

        // Calculate how many characters SHOULD fit
        let expectedWidthChars = Int(bounds.width / charWidth)
        let expectedHeightChars = Int(bounds.height / lineHeight)

        print("=== Character Count Test ===")
        print("Bounds: \(bounds)")
        print("Char Width: \(charWidth)")
        print("Line Height: \(lineHeight)")
        print("Expected Width Chars: \(expectedWidthChars)")
        print("Expected Height Chars: \(expectedHeightChars)")
        print("Actual Grid Width: \(gridDimensions.width)")
        print("Actual Grid Height: \(gridDimensions.height)")
        print("Width Difference: \(expectedWidthChars - gridDimensions.width)")
        print("Height Difference: \(expectedHeightChars - gridDimensions.height)")

        // The calculated grid should match the expected character count
        #expect(
            gridDimensions.width == expectedWidthChars,
            "Grid width should match expected character count. Expected: \(expectedWidthChars), Actual: \(gridDimensions.width)"
        )

        #expect(
            gridDimensions.height == expectedHeightChars,
            "Grid height should match expected character count. Expected: \(expectedHeightChars), Actual: \(gridDimensions.height)"
        )
    }

    @Test func testFontSizeOptimization() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let renderer = createTestRenderer()

        // Calculate optimal grid dimensions
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Test different font sizes to see if we can find a better one
        var bestFontSize: CGFloat = 8.0
        var bestWidthUtilization: CGFloat = 0.0
        var bestHeightUtilization: CGFloat = 0.0

        for testSize in stride(from: 8.0, through: 24.0, by: 0.25) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: testFont)
            let lineHeight = calculateLineHeight(for: testFont)

            let gridWidth = Int(bounds.width / charWidth)
            let gridHeight = Int(bounds.height / lineHeight)

            guard gridWidth > 0 && gridHeight > 0 else { continue }

            let usedWidth = CGFloat(gridWidth) * charWidth
            let usedHeight = CGFloat(gridHeight) * lineHeight

            let widthUtilization = usedWidth / bounds.width
            let heightUtilization = usedHeight / bounds.height

            // Look for better width utilization
            if widthUtilization > bestWidthUtilization {
                bestWidthUtilization = widthUtilization
                bestHeightUtilization = heightUtilization
                bestFontSize = testSize
            }
        }

        print("=== Font Size Optimization Test ===")
        print("Selected Font Size: \(gridDimensions.fontSize)")
        print("Best Font Size: \(bestFontSize)")
        print(
            "Selected Width Utilization: \(CGFloat(gridDimensions.width) * calculateCharacterWidth(for: NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)) / bounds.width * 100)%"
        )
        print("Best Width Utilization: \(bestWidthUtilization * 100)%")

        // The selected font size should be close to the best one
        #expect(
            abs(gridDimensions.fontSize - bestFontSize) <= 0.5,
            "Selected font size should be close to optimal. Selected: \(gridDimensions.fontSize), Best: \(bestFontSize)"
        )
    }

    @Test func testMultipleAspectRatios() async throws {
        let aspectRatios = [
            ("Square", CGRect(x: 0, y: 0, width: 600, height: 600)),
            ("Wide", CGRect(x: 0, y: 0, width: 800, height: 400)),
            ("Tall", CGRect(x: 0, y: 0, width: 400, height: 800)),
            ("Ultra Wide", CGRect(x: 0, y: 0, width: 1200, height: 300)),
            ("Ultra Tall", CGRect(x: 0, y: 0, width: 300, height: 1200)),
        ]

        for (name, bounds) in aspectRatios {
            let renderer = createTestRenderer()
            let entities = createTestEntities(for: bounds)

            // Calculate optimal grid dimensions
            let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Calculate actual content size
            let actualSize = calculateActualContentSize(
                renderer: renderer, entities: entities, bounds: bounds)

            // Calculate utilization percentages
            let widthUtilization = actualSize.width / bounds.width
            let heightUtilization = actualSize.height / bounds.height

            print("=== \(name) Aspect Ratio Test ===")
            print("Bounds: \(bounds)")
            print("Grid: \(gridDimensions.width) x \(gridDimensions.height)")
            print("Font Size: \(gridDimensions.fontSize)")
            print("Width Utilization: \(widthUtilization * 100)%")
            print("Height Utilization: \(heightUtilization * 100)%")
            print("Unused Width: \(bounds.width - actualSize.width)")
            print("Unused Height: \(bounds.height - actualSize.height)")

            // All aspect ratios should have good utilization
            #expect(
                widthUtilization >= 0.90,
                "\(name) should have at least 90% width utilization. Actual: \(widthUtilization * 100)%"
            )
            #expect(
                heightUtilization >= 0.85,
                "\(name) should have at least 85% height utilization. Actual: \(heightUtilization * 100)%"
            )
        }
    }

    @Test func testPreciseWidthCalculation() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let renderer = createTestRenderer()

        // Calculate optimal grid dimensions
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Calculate character metrics
        let optimalFont = NSFont.monospacedSystemFont(
            ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)

        // Calculate the exact width that should be used
        let exactWidth = CGFloat(gridDimensions.width) * charWidth
        let remainingWidth = bounds.width - exactWidth

        print("=== Precise Width Calculation Test ===")
        print("Bounds Width: \(bounds.width)")
        print("Grid Width: \(gridDimensions.width)")
        print("Char Width: \(charWidth)")
        print("Exact Width: \(exactWidth)")
        print("Remaining Width: \(remainingWidth)")
        print("Remaining as %: \(remainingWidth / bounds.width * 100)%")

        // The remaining width should be less than one character width
        #expect(
            remainingWidth < charWidth,
            "Remaining width should be less than one character width. Remaining: \(remainingWidth), Char Width: \(charWidth)"
        )

        // The remaining width should be a small percentage
        #expect(
            remainingWidth / bounds.width < 0.05,
            "Remaining width should be less than 5% of total width. Actual: \(remainingWidth / bounds.width * 100)%"
        )
    }
}
