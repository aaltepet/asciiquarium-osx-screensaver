import AppKit
import Foundation
import Testing

/// Tests to prove width calculation issues and measure actual vs calculated space usage
struct WidthCalculationTests {

    // MARK: - Helper Functions

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    private func simulateOptimalGridCalculation(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        var bestFontSize: CGFloat = 8.0
        var bestHeightUtilization: CGFloat = 0.0

        // Step 1: Find the optimal font size based on height utilization
        for testSize in stride(from: 8.0, through: 24.0, by: 0.25) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let lineHeight = calculateLineHeight(for: testFont)

            let gridHeight = Int(bounds.height / lineHeight)
            guard gridHeight > 0 else { continue }

            // Calculate height utilization
            let usedHeight = CGFloat(gridHeight) * lineHeight
            let heightUtilization = usedHeight / bounds.height

            // Choose the font size that maximizes height utilization
            if heightUtilization > bestHeightUtilization {
                bestHeightUtilization = heightUtilization
                bestFontSize = testSize
            }
        }

        // Step 2: Calculate width based on the optimal font size
        let optimalFont = NSFont.monospacedSystemFont(ofSize: bestFontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)
        let lineHeight = calculateLineHeight(for: optimalFont)

        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        // Ensure we have valid dimensions
        let finalGridWidth = max(1, gridWidth)
        let finalGridHeight = max(1, gridHeight)

        return (width: finalGridWidth, height: finalGridHeight, fontSize: bestFontSize)
    }

    private func calculateActualRenderedSize(
        for bounds: CGRect, gridWidth: Int, gridHeight: Int, fontSize: CGFloat
    ) -> CGSize {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        // Create a test string that represents the full grid
        var lines: [String] = []
        for _ in 0..<gridHeight {
            lines.append(String(repeating: "M", count: gridWidth))
        }

        let testString = lines.joined(separator: "\n")
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: testString, attributes: attributes)

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

    // MARK: - Width Calculation Tests

    @Test func testWidthUtilizationIsMaximized() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid dimensions using our algorithm
        let gridDimensions = simulateOptimalGridCalculation(for: bounds)

        // Calculate actual rendered size
        let actualSize = calculateActualRenderedSize(
            for: bounds,
            gridWidth: gridDimensions.width,
            gridHeight: gridDimensions.height,
            fontSize: gridDimensions.fontSize
        )

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        // Calculate expected size
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
    }

    @Test func testCharacterCountMatchesAvailableSpace() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid dimensions
        let gridDimensions = simulateOptimalGridCalculation(for: bounds)

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

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

    @Test func testPreciseWidthCalculation() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid dimensions
        let gridDimensions = simulateOptimalGridCalculation(for: bounds)

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)

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
        print("Remaining in chars: \(remainingWidth / charWidth)")

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

    @Test func testFontSizeOptimization() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Calculate optimal grid dimensions
        let gridDimensions = simulateOptimalGridCalculation(for: bounds)

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

        let selectedFont = NSFont.monospacedSystemFont(
            ofSize: gridDimensions.fontSize, weight: .regular)
        let selectedCharWidth = calculateCharacterWidth(for: selectedFont)
        let selectedWidthUtilization =
            (CGFloat(gridDimensions.width) * selectedCharWidth) / bounds.width

        print("Selected Width Utilization: \(selectedWidthUtilization * 100)%")
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
            // Calculate optimal grid dimensions
            let gridDimensions = simulateOptimalGridCalculation(for: bounds)

            // Calculate actual rendered size
            let actualSize = calculateActualRenderedSize(
                for: bounds,
                gridWidth: gridDimensions.width,
                gridHeight: gridDimensions.height,
                fontSize: gridDimensions.fontSize
            )

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
}
