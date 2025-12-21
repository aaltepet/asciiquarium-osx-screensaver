//
//  ASCIIRendererTests.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import CoreGraphics
import Testing

@testable import AsciiquariumCore

/// Comprehensive tests for ASCIIRenderer functionality
struct ASCIIRendererTests {

    // MARK: - Basic Rendering Tests

    @Test func testAttributedStringCreation() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let attributedString = renderer.drawCharacter("A", at: CGPoint(x: 0, y: 0), color: .blue)

        // Should return a non-empty attributed string
        #expect(!attributedString.string.isEmpty, "Attributed string should not be empty")
        #expect(attributedString.string == "A", "Should contain correct character")
    }

    @Test func testAttributedStringAttributes() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let attributedString = renderer.drawCharacter("Test", at: CGPoint(x: 0, y: 0), color: .blue)
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
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let testBounds = TestHelpers.generateTestBounds()

        for _ in testBounds {  // bounds no longer impact font/grid in renderer
            let attributedString = renderer.renderScene(
                entities: entities, gridWidth: 80, gridHeight: 24)

            #expect(!attributedString.string.isEmpty, "Should render scene")
            #expect(attributedString.string.contains("~"), "Should contain water surface")
            #expect(attributedString.string.contains("="), "Should contain bottom border")
        }
    }

    @Test func testWaterSurfaceAndBottomBorder() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

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

    // MARK: - Font Management Tests

    @Test func testFontUpdateWithSize() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let originalCharacterWidth = renderer.characterWidth
        let originalLineHeight = renderer.lineHeight

        // Update font to same fixed size should keep dimensions identical
        renderer.updateFont(size: FontMetrics.shared.getDefaultFontSize())

        #expect(renderer.characterWidth == originalCharacterWidth)
        #expect(renderer.lineHeight == originalLineHeight)
    }

    @Test func testFontUpdateWithOptimalSizing() async throws {
        let renderer = TestHelpers.createTestRenderer()
        _ = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Update font with optimal sizing
        renderer.updateFont(size: 12.0)

        // Font should be updated (we can't easily test the exact size without FontMetrics access)
        #expect(
            renderer.characterWidth > 0, "Character width should be positive after optimal sizing")
        #expect(renderer.lineHeight > 0, "Line height should be positive after optimal sizing")
    }

    @Test func testCharacterDimensionsConsistency() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Get dimensions multiple times
        let width1 = renderer.characterWidth
        let height1 = renderer.lineHeight
        let width2 = renderer.characterWidth
        let height2 = renderer.lineHeight

        // Should be consistent
        #expect(width1 == width2, "Character width should be consistent")
        #expect(height1 == height2, "Line height should be consistent")
    }

    // MARK: - Character Positioning Tests

    @Test func testCharacterPositioning() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

        // All lines should have the same width (monospaced)
        let expectedWidth = lines.first?.count ?? 0
        for line in lines {
            if !line.isEmpty {  // Skip empty lines
                #expect(line.count == expectedWidth, "All lines should have same width")
            }
        }
    }

    // MARK: - Color Compositing Tests

    @Test func testDefaultColorAppliedWhenNoColorMask() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Create a single static entity without colorMask
        let e = BaseEntity(
            name: "test",
            type: .castle,
            shape: ["ABCDE"],
            position: Position3D(0, 0, 0)
        )
        e.defaultColor = .red

        let out = renderer.renderScene(entities: [e], gridWidth: 5, gridHeight: 1)

        // Verify all visible characters (first 5) colored red (ignore newline)
        out.enumerateAttributes(in: NSRange(location: 0, length: 5)) { attrs, _, _ in
            if let c = attrs[.foregroundColor] as? NSColor { #expect(c == NSColor.red) }
        }
    }

    @Test func testColorMaskAppliedPerCharacter() async throws {
        let renderer = TestHelpers.createTestRenderer()

        let e = BaseEntity(
            name: "test",
            type: .castle,
            shape: ["ABC"],
            position: Position3D(0, 0, 0)
        )
        e.defaultColor = .blue
        e.colorMask = [
            String([
                ColorCode.red.rawValue, ColorCode.greenBright.rawValue, ColorCode.cyan.rawValue,
            ])
        ]

        let out = renderer.renderScene(entities: [e], gridWidth: 3, gridHeight: 1)

        // Expect colors: r, G, c
        var colors: [NSColor] = []
        out.enumerateAttributes(in: NSRange(location: 0, length: out.length)) { attrs, range, _ in
            // Skip trailing newline
            if range.location >= 3 { return }
            if let c = attrs[.foregroundColor] as? NSColor { colors.append(c) }
        }
        #expect(colors.count >= 3)
        #expect(colors[0] == NSColor.red)
        #expect(colors[1] == NSColor.systemGreen)
        #expect(colors[2] == NSColor.cyan)
    }

    @Test func testTransparentCharSkipsCompositing() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Background line
        let bg = BaseEntity(
            name: "bg",
            type: .castle,
            shape: ["xxxxx"],
            position: Position3D(0, 0, 0)
        )
        bg.defaultColor = .yellow

        // Foreground with spaces as transparent
        let fg = BaseEntity(
            name: "fg",
            type: .castle,
            shape: ["  Z  "],
            position: Position3D(0, 0, 1)
        )
        fg.defaultColor = .red
        fg.transparentChar = " "

        let out = renderer.renderScene(entities: [bg, fg], gridWidth: 5, gridHeight: 1)

        // Extract foreground colors for first 5 chars (one per character position)
        var colors: [NSColor] = []
        for i in 0..<5 {
            var effectiveRange = NSRange(location: 0, length: 0)
            let attrs = out.attributes(at: i, effectiveRange: &effectiveRange)
            if let c = attrs[.foregroundColor] as? NSColor {
                colors.append(c)
            }
        }
        // Expect background yellow where fg is space, and red for 'Z'
        #expect(colors.count == 5)
        #expect(colors[0] == NSColor.yellow)
        #expect(colors[1] == NSColor.yellow)
        #expect(colors[2] == NSColor.red)
        #expect(colors[3] == NSColor.yellow)
        #expect(colors[4] == NSColor.yellow)
    }

    @Test func testColorMaskForcesOpaqueOnSpace() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Background line
        let bg = BaseEntity(
            name: "bg",
            type: .castle,
            shape: ["xxxxx"],
            position: Position3D(0, 0, 0)
        )
        bg.defaultColor = .blue

        // Foreground: spaces with colorMask marking center as opaque
        // colorMask: space = transparent, non-space = opaque
        let fg = BaseEntity(
            name: "fg",
            type: .castle,
            shape: ["     "],
            position: Position3D(0, 0, 1)
        )
        fg.defaultColor = .red
        fg.colorMask = ["  x  "]  // Center space marked as opaque with 'x'

        let out = renderer.renderScene(entities: [bg, fg], gridWidth: 5, gridHeight: 1)

        // Colors for first 5 chars (one per character position)
        var colors: [NSColor] = []
        for i in 0..<5 {
            var effectiveRange = NSRange(location: 0, length: 0)
            let attrs = out.attributes(at: i, effectiveRange: &effectiveRange)
            if let c = attrs[.foregroundColor] as? NSColor {
                colors.append(c)
            }
        }
        // Expect blue, blue, red (forced by colorMask), blue, blue
        #expect(colors.count == 5)
        #expect(colors[0] == NSColor.blue)
        #expect(colors[1] == NSColor.blue)
        #expect(colors[2] == NSColor.red)
        #expect(colors[3] == NSColor.blue)
        #expect(colors[4] == NSColor.blue)
    }

    // MARK: - ColorMask Opacity Tests

    @Test func testColorMaskBasicOpaqueTransparent() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Background: all 'X'
        let bg = BaseEntity(
            name: "bg",
            type: .castle,
            shape: ["XXXXX"],
            position: Position3D(0, 0, 0)
        )
        bg.defaultColor = .blue

        // Foreground: shape with spaces
        // Shape: "  A  " (5 chars: 2 spaces, A, 2 spaces)
        let fg = BaseEntity(
            name: "fg",
            type: .castle,
            shape: ["  A  "],
            position: Position3D(0, 0, 1)
        )
        fg.defaultColor = .red
        // ColorMask: "  x  " means: spaces transparent, A opaque
        fg.colorMask = ["  x  "]

        let out = renderer.renderScene(entities: [bg, fg], gridWidth: 5, gridHeight: 1)
        let renderedString = String(out.string.prefix(5))

        // Expected: "XXAXX" (leading/trailing spaces transparent, A opaque)
        #expect(renderedString == "XXAXX")
    }

    @Test func testColorMaskControlsOpacityInteriorSpacesOpaque() async throws {
        let renderer = TestHelpers.createTestRenderer()

        // Background entity: all '=' characters
        let bg = BaseEntity(
            name: "bg",
            type: .castle,
            shape: ["========="],
            position: Position3D(0, 0, 0)  // z=0 (behind)
        )
        bg.defaultColor = .blue

        // Foreground entity: shape with leading/trailing spaces and interior spaces
        // Shape: "  >   <  " (9 chars: 2 leading spaces, >, 3 interior spaces, <, 2 trailing spaces)
        let fg = BaseEntity(
            name: "fg",
            type: .castle,
            shape: ["  >   <  "],
            position: Position3D(0, 0, 1)  // z=1 (in front)
        )
        fg.defaultColor = .red
        // ColorMask: spaces = transparent, non-space = opaque
        // "  xxxxx  " means: leading spaces transparent, > and 3 interior spaces and < opaque (marked with x), trailing spaces transparent
        // Shape: "  >   <  " (9 chars) -> ColorMask: "  xxxxx  " (9 chars: 2 spaces, 5 x's, 2 spaces)
        fg.colorMask = ["  xxxxx  "]

        let out = renderer.renderScene(entities: [bg, fg], gridWidth: 9, gridHeight: 1)

        // Extract the rendered string (first 9 chars, ignoring newline)
        let renderedString = String(out.string.prefix(9))

        // Debug: print actual vs expected
        let expected = "==>   <=="
        if renderedString != expected {
            print("Expected: '\(expected)' (length: \(expected.count))")
            print("Actual:   '\(renderedString)' (length: \(renderedString.count))")
            for (i, (e, a)) in zip(expected, renderedString).enumerated() {
                if e != a {
                    print(
                        "  Position \(i): expected '\(e)' (code: \(e.unicodeScalars.first!.value)), got '\(a)' (code: \(a.unicodeScalars.first!.value))"
                    )
                }
            }
        }

        // Expected: "==>   <=="
        // - First 2 chars: background (==) - transparent leading spaces
        // - Next 5 chars: foreground (">   <") - opaque including interior spaces
        // - Last 2 chars: background (==) - transparent trailing spaces
        #expect(renderedString == expected)
    }

    @Test func testFullWidthEntityDoesNotOverwriteWithSpaces() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let gridWidth = 10
        let gridHeight = 1

        // Background: a regular entity at z=0
        let bg = BaseEntity(
            name: "bg",
            type: .fish,
            shape: ["XXXXXXXXXX"],
            position: Position3D(0, 0, 0)
        )
        bg.defaultColor = .blue

        // Foreground: a full-width entity at z=1 with spaces
        // We'll use a mock full-width entity
        class MockFullWidth: EntityFullWidth {
            override func getShape(for width: Int) -> [String] {
                return ["  ~~~~~   "]  // 10 chars
            }
        }
        let fg = MockFullWidth(
            name: "fg",
            type: .waterline,
            shape: [""],  // shape ignored for full-width
            position: Position3D(0, 0, 1)
        )
        fg.isFullWidth = true
        fg.defaultColor = .green
        fg.transparentChar = " "

        let out = renderer.renderScene(
            entities: [bg, fg], gridWidth: gridWidth, gridHeight: gridHeight)
        let renderedString = String(out.string.prefix(10))

        // Expected: "XX~~~~~XXX"
        // The spaces in the full-width entity should be transparent, showing the 'X's behind.
        #expect(renderedString == "XX~~~~~XXX")
    }

    @Test func testRenderingOfEntitiesStartingOffscreenTop() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let gridWidth = 5
        let gridHeight = 2

        // Entity starting at y = -1, but height is 2, so row index 1 should be visible at y=0
        let e = BaseEntity(
            name: "offscreen",
            type: .fish,
            shape: [
                "TOPXX",  // row 0 (off-screen)
                "BOTXX",  // row 1 (visible at y=0)
            ],
            position: Position3D(0, -1, 0)
        )
        e.defaultColor = .white

        let out = renderer.renderScene(entities: [e], gridWidth: gridWidth, gridHeight: gridHeight)
        let lines = out.string.components(separatedBy: "\n")

        // line[0] should be "BOTXX" (from row 1 of shape)
        // line[1] should be "     " (empty space)
        #expect(lines[0] == "BOTXX")
        #expect(lines[1] == "     ")
    }

    @Test func testSceneDimensions() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: 80, gridHeight: 24)
        let lines = attributedString.string.components(separatedBy: "\n")

        // Should have reasonable number of lines
        #expect(lines.count > 0, "Should have at least one line")
        #expect(lines.count < 100, "Should not have too many lines")

        // All lines should have reasonable width
        for line in lines {
            if !line.isEmpty {
                #expect(line.count > 0, "Lines should not be empty")
                #expect(line.count < 1000, "Lines should not be too wide")
            }
        }
    }

    // MARK: - Scrollbar Prevention Tests

    // Removed tests tied to old optimal grid calculation

    // Removed rendered size vs calculated dimensions test tied to optimization

    // Removed aspect ratio scrollbar tests tied to optimization

    // Removed dynamic resizing no-scrollbar test tied to optimization

    // Removed grid integrity test tied to optimization outputs

    // MARK: - Edge Case Tests

    // Removed edge case tests tied to optimization

    // Removed font size optimization behavioral test

    // MARK: - Performance Tests

    @Test func testRenderingPerformance() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Measure time for multiple renders
        let (_, executionTime) = TestHelpers.measureExecutionTime {
            for _ in 0..<10 {
                _ = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)
            }
        }

        // Should complete 10 renders in reasonable time (less than 1 second)
        #expect(
            executionTime < 1.0,
            "ASCIIRenderer should be performant. 10 renders took \(executionTime) seconds")
    }

    // MARK: - Consistency Tests

    @Test func testRenderingConsistency() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let entities = TestHelpers.createTestEntities()
        let bounds = CGRect(x: 0, y: 0, width: 800, height: 600)

        // Render the same scene multiple times
        let result1 = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)
        let result2 = renderer.renderScene(entities: entities, gridWidth: 80, gridHeight: 24)

        // Results should be identical
        #expect(
            result1.string == result2.string, "Rendering should be consistent across multiple calls"
        )
    }

    // MARK: - Single Entity Placement Tests

    @Test func testWaterlineEntityPlacement() async throws {
        let renderer = TestHelpers.createTestRenderer()
        let gridWidth = 80
        let gridHeight = 24

        // Create a single waterline entity at a specific position
        let waterlinePosition = Position3D(0, 4, 0)  // x=0 (full-width), y=4 (grid row), z=0
        let waterline = EntityFactory.createWaterline(at: waterlinePosition, segmentIndex: 0)
        let entities = [waterline]

        // Get the cached waterline pattern directly
        let cachedWaterline = waterline.getShape(for: gridWidth)

        // Render the scene using grid coordinates
        let attributedString = renderer.renderScene(
            entities: entities, gridWidth: gridWidth, gridHeight: gridHeight)
        let lines = attributedString.string.components(separatedBy: "\n")

        // Waterline should be at grid row 4
        let expectedGridY = waterlinePosition.y

        // Verify the waterline appears at the correct position
        #expect(expectedGridY < lines.count, "Waterline should be within bounds")

        if expectedGridY < lines.count {
            let waterlineLine = lines[expectedGridY]

            // Verify waterline spans the full width
            #expect(waterlineLine.count >= gridWidth, "Waterline should span full width")

            // Verify the waterline matches the cached pattern
            #expect(
                waterlineLine == cachedWaterline[0],
                "Rendered waterline should match cached pattern")

            // Verify it contains valid waterline characters (waves or carets)
            let hasValidChars = waterlineLine.contains("~") || waterlineLine.contains("^")
            #expect(hasValidChars, "Waterline should contain wave or caret characters")
        }
    }

}
