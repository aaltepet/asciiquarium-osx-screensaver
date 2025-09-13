//
//  ScrollbarPreventionTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

struct ScrollbarPreventionTests {

    // MARK: - Core Scrollbar Prevention Logic Tests

    @Test func testOptimalGridCalculationPreventsScrollbar() async throws {
        let testBounds = [
            CGRect(x: 0, y: 0, width: 400, height: 300),  // Small screen
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium screen
            CGRect(x: 0, y: 0, width: 1200, height: 800),  // Large screen
            CGRect(x: 0, y: 0, width: 1920, height: 1080),  // HD screen
        ]

        for bounds in testBounds {
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)

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

            // Content should fit within bounds (proving no scrollbar needed)
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

    @Test func testAspectRatioHandlingPreventsScrollbar() async throws {
        let aspectRatios = [
            (width: 400.0, height: 300.0, name: "4:3"),
            (width: 800.0, height: 450.0, name: "16:9"),
            (width: 1200.0, height: 400.0, name: "3:1 (wide)"),
            (width: 400.0, height: 1200.0, name: "1:3 (tall)"),
            (width: 600.0, height: 600.0, name: "1:1 (square)"),
        ]

        for (width, height, name) in aspectRatios {
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)

            // Calculate actual pixel dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: font)
            let lineHeight = calculateLineHeight(for: font)

            let actualWidth = CGFloat(optimalGrid.width) * charWidth
            let actualHeight = CGFloat(optimalGrid.height) * lineHeight

            // Content should always fit within bounds (proving no scrollbar needed)
            let tolerance: CGFloat = 2.0
            #expect(
                actualWidth <= bounds.width + tolerance,
                "Content should fit width for \(name) aspect ratio. Content: \(actualWidth), Bounds: \(bounds.width)"
            )
            #expect(
                actualHeight <= bounds.height + tolerance,
                "Content should fit height for \(name) aspect ratio. Content: \(actualHeight), Bounds: \(bounds.height)"
            )

            // Should use most of the available space
            let widthUtilization = actualWidth / bounds.width
            let heightUtilization = actualHeight / bounds.height
            #expect(
                widthUtilization >= 0.7,
                "Should use at least 70% of available width for \(name). Utilization: \(widthUtilization)"
            )
            #expect(
                heightUtilization >= 0.7,
                "Should use at least 70% of available height for \(name). Utilization: \(heightUtilization)"
            )
        }
    }

    @Test func testDynamicResizingMaintainsNoScrollbar() async throws {
        let resizeSequence = [
            CGSize(width: 400, height: 300),
            CGSize(width: 600, height: 400),
            CGSize(width: 800, height: 600),
            CGSize(width: 1000, height: 700),
            CGSize(width: 800, height: 600),  // Resize back down
            CGSize(width: 600, height: 400),
        ]

        for size in resizeSequence {
            let bounds = CGRect(origin: .zero, size: size)
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)

            // Calculate actual pixel dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: font)
            let lineHeight = calculateLineHeight(for: font)

            let actualWidth = CGFloat(optimalGrid.width) * charWidth
            let actualHeight = CGFloat(optimalGrid.height) * lineHeight

            // After each resize, content should still fit perfectly
            let tolerance: CGFloat = 2.0
            #expect(
                actualWidth <= bounds.width + tolerance,
                "Content should fit after resize to \(size). Content: \(actualWidth), Bounds: \(bounds.width)"
            )
            #expect(
                actualHeight <= bounds.height + tolerance,
                "Content should fit after resize to \(size). Content: \(actualHeight), Bounds: \(bounds.height)"
            )
        }
    }

    @Test func testFontSizeOptimizationPreventsScrollbar() async throws {
        let testBounds = [
            CGRect(x: 0, y: 0, width: 200, height: 150),  // Very small
            CGRect(x: 0, y: 0, width: 400, height: 300),  // Small
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium
            CGRect(x: 0, y: 0, width: 1600, height: 1200),  // Large
        ]

        var previousFontSize: CGFloat = 0

        for bounds in testBounds {
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)

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

            // Verify the chosen font size actually prevents scrollbar
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: font)
            let lineHeight = calculateLineHeight(for: font)

            let actualWidth = CGFloat(optimalGrid.width) * charWidth
            let actualHeight = CGFloat(optimalGrid.height) * lineHeight

            let tolerance: CGFloat = 2.0
            #expect(
                actualWidth <= bounds.width + tolerance,
                "Chosen font size should prevent scrollbar. Content: \(actualWidth), Bounds: \(bounds.width)"
            )
            #expect(
                actualHeight <= bounds.height + tolerance,
                "Chosen font size should prevent scrollbar. Content: \(actualHeight), Bounds: \(bounds.height)"
            )

            previousFontSize = optimalGrid.fontSize
        }
    }

    @Test func testEdgeCasesPreventScrollbar() async throws {
        let edgeCases = [
            CGSize(width: 100, height: 100),  // Very small
            CGSize(width: 200, height: 150),  // Small
            CGSize(width: 3000, height: 2000),  // Very large
            CGSize(width: 50, height: 50),  // Extremely small
        ]

        for size in edgeCases {
            let bounds = CGRect(origin: .zero, size: size)
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)

            // Calculate actual pixel dimensions
            let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: font)
            let lineHeight = calculateLineHeight(for: font)

            let actualWidth = CGFloat(optimalGrid.width) * charWidth
            let actualHeight = CGFloat(optimalGrid.height) * lineHeight

            // Even with edge cases, content should fit within bounds
            let tolerance: CGFloat = 5.0  // Larger tolerance for edge cases
            #expect(
                actualWidth <= bounds.width + tolerance,
                "Content should fit width for edge case \(size). Content: \(actualWidth), Bounds: \(bounds.width)"
            )
            #expect(
                actualHeight <= bounds.height + tolerance,
                "Content should fit height for edge case \(size). Content: \(actualHeight), Bounds: \(bounds.height)"
            )

            // Grid dimensions should be reasonable
            #expect(optimalGrid.width > 0, "Grid width should be positive for edge case \(size)")
            #expect(optimalGrid.height > 0, "Grid height should be positive for edge case \(size)")
        }
    }

    @Test func testConsistencyPreventsScrollbar() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Run the calculation multiple times with the same input
        var results: [(width: Int, height: Int, fontSize: CGFloat)] = []

        for _ in 0..<5 {
            let optimalGrid = calculateOptimalGridDimensions(for: bounds)
            results.append(
                (
                    width: optimalGrid.width,
                    height: optimalGrid.height,
                    fontSize: optimalGrid.fontSize
                ))
        }

        // All results should be identical
        let firstResult = results[0]
        for (index, result) in results.enumerated() {
            #expect(
                result.width == firstResult.width,
                "Grid width should be consistent across runs. Run \(index): \(result.width), First: \(firstResult.width)"
            )
            #expect(
                result.height == firstResult.height,
                "Grid height should be consistent across runs. Run \(index): \(result.height), First: \(firstResult.height)"
            )
            #expect(
                result.fontSize == firstResult.fontSize,
                "Font size should be consistent across runs. Run \(index): \(result.fontSize), First: \(firstResult.fontSize)"
            )
        }
    }

    // MARK: - Helper Functions

    private func calculateOptimalGridDimensions(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        var bestGrid = (width: 0, height: 0, fontSize: CGFloat(8.0))
        var bestFit = 0.0

        // Try different font sizes to find the best fit
        for testSize in stride(from: 8.0, through: 24.0, by: 0.5) {
            let testFont = NSFont.monospacedSystemFont(ofSize: testSize, weight: .regular)
            let charWidth = calculateCharacterWidth(for: testFont)
            let lineHeight = calculateLineHeight(for: testFont)

            let gridWidth = Int(bounds.width / charWidth)
            let gridHeight = Int(bounds.height / lineHeight)

            // Calculate how well this fits (area used)
            let usedWidth = CGFloat(gridWidth) * charWidth
            let usedHeight = CGFloat(gridHeight) * lineHeight
            let fit = (usedWidth * usedHeight) / (bounds.width * bounds.height)

            if fit > bestFit && gridWidth > 0 && gridHeight > 0 {
                bestFit = fit
                bestGrid = (width: gridWidth, height: gridHeight, fontSize: testSize)
            }
        }

        return bestGrid
    }

    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let sampleString = "M"
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return sampleString.size(withAttributes: attributes).width
    }

    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }
}
