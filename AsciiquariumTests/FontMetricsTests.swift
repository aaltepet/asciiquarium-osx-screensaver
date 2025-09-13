//
//  FontMetricsTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

struct FontMetricsTests {

    // MARK: - Font Metrics Helper Functions

    private func createTestRenderer() -> (
        characterWidth: CGFloat, lineHeight: CGFloat, fontSize: CGFloat
    ) {
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)

        // Calculate character width
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let characterWidth = sampleString.size(withAttributes: attributes).width

        // Calculate line height
        let lineHeight = font.ascender - font.descender + font.leading

        return (characterWidth, lineHeight, 14.0)
    }

    private func calculateOptimalFontSize(for bounds: CGRect) -> CGFloat {
        let baseSize: CGFloat = 12.0
        let maxCharactersWidth = Int(bounds.width / (baseSize * 0.6))
        let maxCharactersHeight = Int(bounds.height / (baseSize * 1.2))
        let maxCharacters = min(maxCharactersWidth, maxCharactersHeight)
        let fontSize = min(baseSize * CGFloat(maxCharacters) / 50.0, 24.0)
        return max(fontSize, 8.0)
    }

    private func calculateGridDimensions(
        for bounds: CGRect, characterWidth: CGFloat, lineHeight: CGFloat
    ) -> (width: Int, height: Int) {
        let gridWidth = Int(bounds.width / characterWidth)
        let gridHeight = Int(bounds.height / lineHeight)
        return (gridWidth, gridHeight)
    }

    // MARK: - Font Size Calculation Tests

    @Test func testFontSizeCalculationForDifferentBounds() async throws {
        // Test various screen sizes
        let testBounds = [
            CGRect(x: 0, y: 0, width: 320, height: 240),  // Small screen
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium screen
            CGRect(x: 0, y: 0, width: 1920, height: 1080),  // Large screen
            CGRect(x: 0, y: 0, width: 3840, height: 2160),  // 4K screen
        ]

        for bounds in testBounds {
            // Test that font size calculation doesn't crash
            let fontSize = calculateOptimalFontSize(for: bounds)

            // Font size should be positive and reasonable
            #expect(fontSize > 0, "Font size should be positive for bounds: \(bounds)")
            #expect(fontSize < 100, "Font size should be reasonable for bounds: \(bounds)")

            // Font size should scale appropriately with screen size
            if bounds.width > 1000 {
                #expect(fontSize > 10, "Large screens should have larger font size")
            }
        }
    }

    @Test func testCharacterDimensionsAccuracy() async throws {
        let metrics = createTestRenderer()

        // Dimensions should be positive
        #expect(metrics.characterWidth > 0, "Character width should be positive")
        #expect(metrics.lineHeight > 0, "Line height should be positive")

        // Character width should be reasonable for monospaced font
        #expect(metrics.characterWidth > 5, "Character width should be at least 5 points")
        #expect(metrics.characterWidth < 50, "Character width should be less than 50 points")

        // Line height should be larger than character width
        #expect(
            metrics.lineHeight > metrics.characterWidth,
            "Line height should be larger than character width")
    }

    @Test func testCharacterDimensionsMatchActualRendering() async throws {
        let metrics = createTestRenderer()

        // Create a test string
        let testString = "M"
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]

        // Get actual rendered size
        let actualSize = testString.size(withAttributes: attributes)

        // Calculated width should match actual width (within tolerance)
        let widthTolerance: CGFloat = 1.0
        #expect(
            abs(metrics.characterWidth - actualSize.width) <= widthTolerance,
            "Calculated width should match actual width. Calculated: \(metrics.characterWidth), Actual: \(actualSize.width)"
        )

        // Calculated height should be reasonable compared to actual height
        #expect(
            metrics.lineHeight >= actualSize.height,
            "Calculated height should be at least actual height")
    }

    @Test func testFontSizingWithVariousAspectRatios() async throws {
        // Test different aspect ratios
        let aspectRatios = [
            (width: 400.0, height: 300.0),  // 4:3
            (width: 800.0, height: 450.0),  // 16:9
            (width: 1200.0, height: 400.0),  // 3:1 (very wide)
            (width: 400.0, height: 1200.0),  // 1:3 (very tall)
            (width: 600.0, height: 600.0),  // 1:1 (square)
        ]

        for (width, height) in aspectRatios {
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let fontSize = calculateOptimalFontSize(for: bounds)

            // Font size should be positive for all aspect ratios
            #expect(
                fontSize > 0, "Font size should be positive for aspect ratio \(width):\(height)")

            // Font size should be reasonable
            #expect(fontSize > 5, "Font size should be at least 5 points")
            #expect(fontSize < 100, "Font size should be less than 100 points")
        }
    }

    @Test func testGridDimensionsCalculation() async throws {
        let metrics = createTestRenderer()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Get grid dimensions
        let gridDimensions = calculateGridDimensions(
            for: bounds, characterWidth: metrics.characterWidth, lineHeight: metrics.lineHeight)

        // Grid dimensions should be positive integers
        #expect(gridDimensions.width > 0, "Grid width should be positive")
        #expect(gridDimensions.height > 0, "Grid height should be positive")

        // Grid should fit within bounds
        #expect(
            CGFloat(gridDimensions.width) * metrics.characterWidth <= bounds.width,
            "Grid width should fit within bounds")
        #expect(
            CGFloat(gridDimensions.height) * metrics.lineHeight <= bounds.height,
            "Grid height should fit within bounds")
    }

    @Test func testFontMetricsConsistency() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Get metrics multiple times
        let metrics1 = createTestRenderer()
        let fontSize1 = calculateOptimalFontSize(for: bounds)

        let metrics2 = createTestRenderer()
        let fontSize2 = calculateOptimalFontSize(for: bounds)

        // Metrics should be consistent
        #expect(
            metrics1.characterWidth == metrics2.characterWidth,
            "Character width should be consistent")
        #expect(metrics1.lineHeight == metrics2.lineHeight, "Line height should be consistent")
        #expect(fontSize1 == fontSize2, "Font size should be consistent")
    }
}
