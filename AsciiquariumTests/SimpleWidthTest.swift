import AppKit
import Foundation
import Testing

/// Simple test to prove width utilization issues
struct SimpleWidthTest {

    @Test func testWidthUtilization() async throws {
        print("=== Width Utilization Test ===")

        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Simulate the two-step algorithm
        let result = Self.calculateOptimalGridDimensions(for: bounds)

        print("Bounds: \(bounds)")
        print("Grid: \(result.width) x \(result.height)")
        print("Font Size: \(result.fontSize)")

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: result.fontSize, weight: .regular)
        let charWidth = Self.calculateCharacterWidth(for: font)
        let lineHeight = Self.calculateLineHeight(for: font)

        print("Char Width: \(charWidth)")
        print("Line Height: \(lineHeight)")

        // Calculate expected vs actual usage
        let expectedWidth = CGFloat(result.width) * charWidth
        let expectedHeight = CGFloat(result.height) * lineHeight

        print("Expected Width: \(expectedWidth)")
        print("Expected Height: \(expectedHeight)")

        let widthUtilization = expectedWidth / bounds.width
        let heightUtilization = expectedHeight / bounds.height

        print("Width Utilization: \(widthUtilization * 100)%")
        print("Height Utilization: \(heightUtilization * 100)%")

        let unusedWidth = bounds.width - expectedWidth
        let unusedHeight = bounds.height - expectedHeight

        print("Unused Width: \(unusedWidth) pixels")
        print("Unused Height: \(unusedHeight) pixels")
        print("Unused Width as %: \(unusedWidth / bounds.width * 100)%")
        print("Unused Height as %: \(unusedHeight / bounds.height * 100)%")

        // Calculate how many more characters could fit
        let additionalChars = Int(unusedWidth / charWidth)
        print("Additional characters that could fit: \(additionalChars)")

        // Test different font sizes to see if we can do better
        print("\n=== Testing Different Font Sizes ===")
        var bestWidthUtilization: CGFloat = 0.0
        var bestFontSize: CGFloat = 8.0

        for testSize in stride(from: 8.0, through: 24.0, by: 0.25) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let testCharWidth = Self.calculateCharacterWidth(for: testFont)
            let testLineHeight = Self.calculateLineHeight(for: testFont)

            let testGridWidth = Int(bounds.width / testCharWidth)
            let testGridHeight = Int(bounds.height / testLineHeight)

            guard testGridWidth > 0 && testGridHeight > 0 else { continue }

            let testUsedWidth = CGFloat(testGridWidth) * testCharWidth
            let testWidthUtilization = testUsedWidth / bounds.width

            if testWidthUtilization > bestWidthUtilization {
                bestWidthUtilization = testWidthUtilization
                bestFontSize = testSize
            }
        }

        print("Best font size for width: \(bestFontSize)")
        print("Best width utilization: \(bestWidthUtilization * 100)%")

        // Test the best font size
        let bestFont = NSFont.monospacedSystemFont(ofSize: bestFontSize, weight: .regular)
        let bestCharWidth = Self.calculateCharacterWidth(for: bestFont)
        let bestLineHeight = Self.calculateLineHeight(for: bestFont)
        let bestGridWidth = Int(bounds.width / bestCharWidth)
        let bestGridHeight = Int(bounds.height / bestLineHeight)
        let bestUsedWidth = CGFloat(bestGridWidth) * bestCharWidth
        let bestUnusedWidth = bounds.width - bestUsedWidth

        print("Best grid: \(bestGridWidth) x \(bestGridHeight)")
        print("Best unused width: \(bestUnusedWidth) pixels")
        print("Best unused width as %: \(bestUnusedWidth / bounds.width * 100)%")
        print("Best additional characters: \(Int(bestUnusedWidth / bestCharWidth))")
    }

    private static func calculateOptimalGridDimensions(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        var bestFontSize: CGFloat = 8.0
        var bestHeightUtilization: CGFloat = 0.0

        // Step 1: Find the optimal font size based on height utilization
        for testSize in stride(from: 8.0, through: 24.0, by: 0.25) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let lineHeight = Self.calculateLineHeight(for: testFont)

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
        let charWidth = Self.calculateCharacterWidth(for: optimalFont)
        let lineHeight = Self.calculateLineHeight(for: optimalFont)

        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        // Ensure we have valid dimensions
        let finalGridWidth = max(1, gridWidth)
        let finalGridHeight = max(1, gridHeight)

        return (width: finalGridWidth, height: finalGridHeight, fontSize: bestFontSize)
    }

    private static func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private static func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }
}
