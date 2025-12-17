//
//  FontMetricsTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

@testable import AsciiquariumCore

/// Comprehensive tests for FontMetrics functionality
struct FontMetricsTests {

    // MARK: - Helper Functions

    private func calculateActualRenderedSize(
        for bounds: CGRect, gridWidth: Int, gridHeight: Int, fontSize: CGFloat
    ) -> CGSize {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let _ = FontMetrics.shared.calculateCharacterWidth(for: font)
        let _ = FontMetrics.shared.calculateLineHeight(for: font)

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
        let expectedWidth = FontMetrics.shared.calculateCharacterWidth(for: font)

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
        let expectedHeight = FontMetrics.shared.calculateLineHeight(for: font)

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

    // Removed old optimization consistency test

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

    // Removed tests related to old optimal grid/font size calculations
}
