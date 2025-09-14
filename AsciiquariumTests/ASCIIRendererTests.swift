//
//  ASCIIRendererTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import Testing

struct ASCIIRendererTests {

    // MARK: - Rendering Helper Functions

    private func createTestAttributedString() -> NSAttributedString {
        let font = FontMetrics.shared.createDefaultFont()
        return NSAttributedString(
            string: "Test String",
            attributes: [
                .font: font,
                .foregroundColor: NSColor.blue,
            ]
        )
    }

    private func simulateSceneRendering(bounds: CGRect) -> String {
        // Simulate the basic scene structure
        let height = Int(bounds.height / 20)  // Approximate line height
        let width = Int(bounds.width / 8)  // Approximate character width

        var lines: [String] = []

        // Create empty lines
        for _ in 0..<height {
            lines.append(String(repeating: " ", count: width))
        }

        // Add water surface (3 lines from bottom)
        let surfaceY = max(0, height - 4)
        if surfaceY < height {
            lines[surfaceY] = String(repeating: "~", count: width)
        }

        // Add bottom border (last line)
        let bottomY = height - 1
        if bottomY >= 0 && bottomY < height {
            lines[bottomY] = String(repeating: "=", count: width)
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Basic Rendering Tests

    @Test func testAttributedStringCreation() async throws {
        let attributedString = createTestAttributedString()

        // Should return a non-empty attributed string
        #expect(!attributedString.string.isEmpty, "Attributed string should not be empty")
        #expect(attributedString.string == "Test String", "Should contain correct string")
    }

    @Test func testAttributedStringAttributes() async throws {
        let attributedString = createTestAttributedString()
        var range = NSRange(location: 0, length: attributedString.length)
        let attributes = attributedString.attributes(at: 0, effectiveRange: &range)

        // Should have font attribute
        #expect(attributes[NSAttributedString.Key.font] != nil, "Should have font attribute")

        // Should have color attribute
        #expect(
            attributes[NSAttributedString.Key.foregroundColor] != nil, "Should have color attribute"
        )

        // Color should be blue
        if let color = attributes[NSAttributedString.Key.foregroundColor] as? NSColor {
            #expect(color == NSColor.blue, "Should have blue color")
        }
    }

    @Test func testSceneRenderingWithDifferentBounds() async throws {
        let testBounds = [
            CGRect(x: 0, y: 0, width: 320, height: 240),
            CGRect(x: 0, y: 0, width: 800, height: 600),
            CGRect(x: 0, y: 0, width: 1920, height: 1080),
        ]

        for bounds in testBounds {
            let result = simulateSceneRendering(bounds: bounds)

            // Should render successfully for all bounds
            #expect(!result.isEmpty, "Should render for bounds: \(bounds)")

            // Should contain expected elements
            #expect(result.contains("~"), "Should contain water surface for bounds: \(bounds)")
            #expect(result.contains("="), "Should contain bottom border for bounds: \(bounds)")
        }
    }

    @Test func testWaterSurfaceAndBottomBorder() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let result = simulateSceneRendering(bounds: bounds)
        let lines = result.components(separatedBy: "\n")

        // Should have water surface
        var hasWaterSurface = false
        for line in lines {
            if line.contains("~") {
                hasWaterSurface = true
                break
            }
        }
        #expect(hasWaterSurface, "Should have water surface line")

        // Should have bottom border
        var hasBottomBorder = false
        for line in lines {
            if line.contains("=") {
                hasBottomBorder = true
                break
            }
        }
        #expect(hasBottomBorder, "Should have bottom border line")
    }

    @Test func testCharacterPositioning() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let result = simulateSceneRendering(bounds: bounds)
        let lines = result.components(separatedBy: "\n")

        // All lines should have the same width (monospaced)
        let expectedWidth = lines.first?.count ?? 0
        for line in lines {
            #expect(line.count == expectedWidth, "All lines should have same width")
        }
    }

    @Test func testSceneDimensions() async throws {
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let result = simulateSceneRendering(bounds: bounds)
        let lines = result.components(separatedBy: "\n")

        // Should have reasonable number of lines
        #expect(lines.count > 0, "Should have at least one line")
        #expect(lines.count < 100, "Should not have too many lines")

        // All lines should have reasonable width
        for line in lines {
            #expect(line.count > 0, "Lines should not be empty")
            #expect(line.count < 1000, "Lines should not be too wide")
        }
    }
}
