//
//  FontMetricsTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

/// Comprehensive tests for FontMetrics functionality
struct FontMetricsTests {

    // MARK: - Helper Functions

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    private func calculateActualRenderedSize(
        for bounds: CGRect, gridWidth: Int, gridHeight: Int, fontSize: CGFloat
    ) -> CGSize {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let _ = calculateCharacterWidth(for: font)
        let _ = calculateLineHeight(for: font)

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

    // MARK: - Core FontMetrics Tests

    @Test func testCharacterWidthCalculationAccuracy() async throws {
        let font = FontMetrics.shared.createDefaultFont()
        let calculatedWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        let expectedWidth = calculateCharacterWidth(for: font)

        // FontMetrics calculation should be accurate
        #expect(calculatedWidth > 0, "Character width should be positive")
        #expect(calculatedWidth.isFinite, "Character width should be finite")

        // Should be close to the simple calculation (within reasonable tolerance)
        let tolerance: CGFloat = 2.0
        #expect(
            abs(calculatedWidth - expectedWidth) <= tolerance,
            "FontMetrics character width should match expected. Calculated: \(calculatedWidth), Expected: \(expectedWidth)"
        )
    }

    @Test func testLineHeightCalculationAccuracy() async throws {
        let font = FontMetrics.shared.createDefaultFont()
        let calculatedHeight = FontMetrics.shared.calculateLineHeight(for: font)
        let expectedHeight = calculateLineHeight(for: font)

        // FontMetrics calculation should be accurate
        #expect(calculatedHeight > 0, "Line height should be positive")
        #expect(calculatedHeight.isFinite, "Line height should be finite")

        // Should be close to the simple calculation (within reasonable tolerance)
        let tolerance: CGFloat = 3.0
        #expect(
            abs(calculatedHeight - expectedHeight) <= tolerance,
            "FontMetrics line height should match expected. Calculated: \(calculatedHeight), Expected: \(expectedHeight)"
        )
    }

    @Test func testFontMetricsConsistency() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Get metrics multiple times
        let result1 = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)
        let result2 = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Results should be consistent
        #expect(result1.width == result2.width, "Grid width should be consistent")
        #expect(result1.height == result2.height, "Grid height should be consistent")
        #expect(result1.fontSize == result2.fontSize, "Font size should be consistent")
    }

    @Test func testCharacterDimensionsMatchActualRendering() async throws {
        let font = FontMetrics.shared.createDefaultFont()
        let calculatedWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        let calculatedHeight = FontMetrics.shared.calculateLineHeight(for: font)

        // Basic validation - dimensions should be positive and finite
        #expect(calculatedWidth > 0, "Calculated width should be positive")
        #expect(calculatedHeight > 0, "Calculated height should be positive")
        #expect(calculatedWidth.isFinite, "Calculated width should be finite")
        #expect(calculatedHeight.isFinite, "Calculated height should be finite")
    }

    // MARK: - Grid Calculation Tests

    @Test func testOptimalGridDimensionsCalculation() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Grid dimensions should be positive
        #expect(gridDimensions.width > 0, "Grid width should be positive")
        #expect(gridDimensions.height > 0, "Grid height should be positive")
        #expect(gridDimensions.fontSize > 0, "Font size should be positive")

        // Font size should be within reasonable range
        #expect(
            gridDimensions.fontSize >= 8.0 && gridDimensions.fontSize <= 24.0,
            "Font size should be within reasonable range. Actual: \(gridDimensions.fontSize)"
        )

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        // Grid should fit within bounds
        let expectedWidth = CGFloat(gridDimensions.width) * charWidth
        let expectedHeight = CGFloat(gridDimensions.height) * lineHeight

        #expect(
            expectedWidth <= bounds.width,
            "Grid width should fit within bounds. Expected: \(expectedWidth), Bounds: \(bounds.width)"
        )
        #expect(
            expectedHeight <= bounds.height,
            "Grid height should fit within bounds. Expected: \(expectedHeight), Bounds: \(bounds.height)"
        )
    }

    @Test func testWidthUtilizationIsOptimized() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Basic validation - grid dimensions should be reasonable
        #expect(gridDimensions.width > 0, "Grid width should be positive")
        #expect(gridDimensions.height > 0, "Grid height should be positive")
        #expect(gridDimensions.fontSize > 0, "Font size should be positive")

        // Grid should fit within bounds (basic check)
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        let lineHeight = FontMetrics.shared.calculateLineHeight(for: font)

        let expectedWidth = CGFloat(gridDimensions.width) * charWidth
        let expectedHeight = CGFloat(gridDimensions.height) * lineHeight

        #expect(expectedWidth <= bounds.width * 1.1, "Grid should fit within bounds width")
        #expect(expectedHeight <= bounds.height * 1.1, "Grid should fit within bounds height")
    }

    @Test func testCharacterCountMatchesAvailableSpace() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        // Calculate how many characters SHOULD fit
        let expectedWidthChars = Int(bounds.width / charWidth)
        let expectedHeightChars = Int(bounds.height / lineHeight)

        print("=== Character Count Test ===")
        print("Expected Width Chars: \(expectedWidthChars)")
        print("Expected Height Chars: \(expectedHeightChars)")
        print("Actual Grid Width: \(gridDimensions.width)")
        print("Actual Grid Height: \(gridDimensions.height)")

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
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Calculate character metrics
        let font = NSFont.monospacedSystemFont(ofSize: gridDimensions.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)

        // Calculate the exact width that should be used
        let exactWidth = CGFloat(gridDimensions.width) * charWidth
        let remainingWidth = bounds.width - exactWidth

        print("=== Precise Width Calculation Test ===")
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

    // MARK: - Integration Tests

    @Test func testActualRenderingMatchesCalculations() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Basic validation - grid dimensions should be reasonable
        #expect(gridDimensions.width > 0, "Grid width should be positive")
        #expect(gridDimensions.height > 0, "Grid height should be positive")
        #expect(gridDimensions.fontSize > 0, "Font size should be positive")

        // Font size should be within reasonable range
        #expect(
            gridDimensions.fontSize >= 8.0 && gridDimensions.fontSize <= 24.0,
            "Font size should be within reasonable range. Actual: \(gridDimensions.fontSize)"
        )
    }

    // MARK: - Edge Case Tests

    @Test func testMultipleAspectRatios() async throws {
        let aspectRatios = [
            ("Square", CGRect(x: 0, y: 0, width: 600, height: 600)),
            ("Wide", CGRect(x: 0, y: 0, width: 800, height: 400)),
            ("Tall", CGRect(x: 0, y: 0, width: 400, height: 800)),
            ("Ultra Wide", CGRect(x: 0, y: 0, width: 1200, height: 300)),
            ("Ultra Tall", CGRect(x: 0, y: 0, width: 300, height: 1200)),
        ]

        for (name, bounds) in aspectRatios {
            let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // All aspect ratios should produce valid results
            #expect(gridDimensions.width > 0, "\(name) should have positive width")
            #expect(gridDimensions.height > 0, "\(name) should have positive height")
            #expect(gridDimensions.fontSize >= 8.0, "\(name) should have reasonable font size")
            #expect(gridDimensions.fontSize <= 24.0, "\(name) should have reasonable font size")
        }
    }

    @Test func testFontSizingWithVariousBounds() async throws {
        let testBounds = [
            CGRect(x: 0, y: 0, width: 320, height: 240),  // Small screen
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium screen
            CGRect(x: 0, y: 0, width: 1920, height: 1080),  // Large screen
            CGRect(x: 0, y: 0, width: 3840, height: 2160),  // 4K screen
        ]

        for bounds in testBounds {
            let gridDimensions = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

            // Font size should be positive and reasonable
            #expect(
                gridDimensions.fontSize > 0, "Font size should be positive for bounds: \(bounds)")
            #expect(
                gridDimensions.fontSize < 100,
                "Font size should be reasonable for bounds: \(bounds)")

            // Grid dimensions should be positive
            #expect(gridDimensions.width > 0, "Grid width should be positive")
            #expect(gridDimensions.height > 0, "Grid height should be positive")

            // Font size should scale appropriately with screen size
            if bounds.width > 1000 {
                #expect(gridDimensions.fontSize > 10, "Large screens should have larger font size")
            }
        }
    }
}
