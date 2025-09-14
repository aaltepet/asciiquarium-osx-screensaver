//
//  ContentViewScrollbarTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import SwiftUI
import Testing

struct ContentViewScrollbarTests {

    // MARK: - Test Helper Functions

    private func createTestRenderer() -> ASCIIRenderer {
        return ASCIIRenderer()
    }

    private func createTestEngine() -> AsciiquariumEngine {
        return AsciiquariumEngine()
    }

    private func simulateContentViewRendering(bounds: CGRect) -> (
        contentSize: CGSize, displaySize: CGSize
    ) {
        let renderer = createTestRenderer()
        let engine = createTestEngine()

        // Calculate optimal grid dimensions
        let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: bounds)

        // Update engine with optimal dimensions
        engine.updateSceneDimensions(
            width: optimalGrid.width,
            height: optimalGrid.height,
            fontSize: optimalGrid.fontSize
        )

        // Render the scene
        let attributedString = renderer.renderScene(entities: engine.entities, in: bounds)

        // Calculate actual content dimensions
        let font = NSFont.monospacedSystemFont(ofSize: optimalGrid.fontSize, weight: .regular)
        let contentSize = calculateAttributedStringSize(
            attributedString: attributedString, font: font)

        // The display size should match the engine's scene dimensions
        let displaySize = CGSize(width: engine.sceneWidth, height: engine.sceneHeight)

        return (contentSize, displaySize)
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

    // MARK: - ContentView Scrollbar Prevention Tests

    @Test func testContentViewNoScrollbarWithVariousSizes() async throws {
        let testSizes = [
            CGSize(width: 400, height: 300),  // Small
            CGSize(width: 600, height: 400),  // Medium-small
            CGSize(width: 800, height: 600),  // Medium
            CGSize(width: 1000, height: 700),  // Large
            CGSize(width: 1200, height: 800),  // Very large
            CGSize(width: 1920, height: 1080),  // HD
        ]

        for size in testSizes {
            let bounds = CGRect(origin: .zero, size: size)
            let result = simulateContentViewRendering(bounds: bounds)

            // Content size should fit within display size (proving no scrollbar needed)
            let tolerance: CGFloat = 3.0
            #expect(
                result.contentSize.width <= result.displaySize.width + tolerance,
                "Content width should fit display width for size \(size). Content: \(result.contentSize.width), Display: \(result.displaySize.width)"
            )
            #expect(
                result.contentSize.height <= result.displaySize.height + tolerance,
                "Content height should fit display height for size \(size). Content: \(result.contentSize.height), Display: \(result.displaySize.height)"
            )

            // Display size should be reasonable (not too small or too large)
            #expect(result.displaySize.width > 0, "Display width should be positive")
            #expect(result.displaySize.height > 0, "Display height should be positive")
            #expect(
                result.displaySize.width <= size.width,
                "Display width should not exceed available width")
            #expect(
                result.displaySize.height <= size.height,
                "Display height should not exceed available height")
        }
    }

    @Test func testContentViewAspectRatioHandling() async throws {
        let aspectRatios = [
            (width: 400.0, height: 300.0, name: "4:3"),
            (width: 800.0, height: 450.0, name: "16:9"),
            (width: 1200.0, height: 400.0, name: "3:1 (wide)"),
            (width: 400.0, height: 1200.0, name: "1:3 (tall)"),
            (width: 600.0, height: 600.0, name: "1:1 (square)"),
        ]

        for (width, height, name) in aspectRatios {
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let result = simulateContentViewRendering(bounds: bounds)

            // Content should always fit within display area
            let tolerance: CGFloat = 2.0
            #expect(
                result.contentSize.width <= result.displaySize.width + tolerance,
                "Content should fit width for \(name) aspect ratio. Content: \(result.contentSize.width), Display: \(result.displaySize.width)"
            )
            #expect(
                result.contentSize.height <= result.displaySize.height + tolerance,
                "Content should fit height for \(name) aspect ratio. Content: \(result.contentSize.height), Display: \(result.displaySize.height)"
            )

            // Display area should use most of the available space
            let widthUtilization = result.displaySize.width / width
            let heightUtilization = result.displaySize.height / height
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

    @Test func testContentViewDynamicResizing() async throws {
        // Simulate window resizing by testing multiple sizes in sequence
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
            let result = simulateContentViewRendering(bounds: bounds)

            // After each resize, content should still fit perfectly
            let tolerance: CGFloat = 2.0
            #expect(
                result.contentSize.width <= result.displaySize.width + tolerance,
                "Content should fit after resize to \(size). Content: \(result.contentSize.width), Display: \(result.displaySize.width)"
            )
            #expect(
                result.contentSize.height <= result.displaySize.height + tolerance,
                "Content should fit after resize to \(size). Content: \(result.contentSize.height), Display: \(result.displaySize.height)"
            )
        }
    }

    @Test func testContentViewFontSizeConsistency() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let result = simulateContentViewRendering(bounds: bounds)

        // Multiple renders with the same bounds should produce consistent results
        let result2 = simulateContentViewRendering(bounds: bounds)

        let tolerance: CGFloat = 1.0
        #expect(
            abs(result.contentSize.width - result2.contentSize.width) <= tolerance,
            "Content width should be consistent across multiple renders")
        #expect(
            abs(result.contentSize.height - result2.contentSize.height) <= tolerance,
            "Content height should be consistent across multiple renders")
        #expect(
            abs(result.displaySize.width - result2.displaySize.width) <= tolerance,
            "Display width should be consistent across multiple renders")
        #expect(
            abs(result.displaySize.height - result2.displaySize.height) <= tolerance,
            "Display height should be consistent across multiple renders")
    }

    @Test func testContentViewEdgeCases() async throws {
        let edgeCases = [
            CGSize(width: 100, height: 100),  // Very small
            CGSize(width: 200, height: 150),  // Small
            CGSize(width: 3000, height: 2000),  // Very large
            CGSize(width: 50, height: 50),  // Extremely small
        ]

        for size in edgeCases {
            let bounds = CGRect(origin: .zero, size: size)
            let result = simulateContentViewRendering(bounds: bounds)

            // Even with edge cases, content should fit within display area
            let tolerance: CGFloat = 5.0  // Larger tolerance for edge cases
            #expect(
                result.contentSize.width <= result.displaySize.width + tolerance,
                "Content should fit width for edge case \(size). Content: \(result.contentSize.width), Display: \(result.displaySize.width)"
            )
            #expect(
                result.contentSize.height <= result.displaySize.height + tolerance,
                "Content should fit height for edge case \(size). Content: \(result.contentSize.height), Display: \(result.displaySize.height)"
            )

            // Display size should be reasonable
            #expect(
                result.displaySize.width > 0,
                "Display width should be positive for edge case \(size)")
            #expect(
                result.displaySize.height > 0,
                "Display height should be positive for edge case \(size)")
        }
    }

    @Test func testContentViewPerformance() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Measure time for multiple renders
        let startTime = CFAbsoluteTimeGetCurrent()

        for _ in 0..<10 {
            _ = simulateContentViewRendering(bounds: bounds)
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime

        // Should complete 10 renders in reasonable time (less than 1 second)
        #expect(
            totalTime < 1.0,
            "ContentView rendering should be performant. 10 renders took \(totalTime) seconds")
    }
}
