//
//  TestHelpers.swift
//  AsciiquariumTests
//
//  Created by Andy Altepeter on 9/10/25.
//

import AppKit
import CoreGraphics
import Foundation
import SwiftUI

/// Shared test helper functions to eliminate duplication across test files
struct TestHelpers {

    // MARK: - Test Object Creation

    static func createTestRenderer() -> ASCIIRenderer {
        return ASCIIRenderer()
    }

    static func createTestEngine() -> AsciiquariumEngine {
        return AsciiquariumEngine()
    }

    static func createTestEntities() -> [Entity] {
        return [
            EntityFactory.createFish(at: Position3D(100, 100, 10)),
            EntityFactory.createFish(at: Position3D(200, 150, 15)),
            EntityFactory.createFish(at: Position3D(300, 200, 5)),
        ]
    }

    // MARK: - Content Size Calculation

    static func calculateAttributedStringSize(attributedString: NSAttributedString, font: NSFont)
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

    // MARK: - Test Data Generation

    static func generateTestBounds() -> [CGRect] {
        return [
            CGRect(x: 0, y: 0, width: 400, height: 300),  // Small screen
            CGRect(x: 0, y: 0, width: 800, height: 600),  // Medium screen
            CGRect(x: 0, y: 0, width: 1200, height: 800),  // Large screen
            CGRect(x: 0, y: 0, width: 1920, height: 1080),  // HD screen
        ]
    }

    static func generateAspectRatioBounds() -> [(width: Double, height: Double, name: String)] {
        return [
            (width: 400.0, height: 300.0, name: "4:3"),
            (width: 800.0, height: 450.0, name: "16:9"),
            (width: 1200.0, height: 400.0, name: "3:1 (wide)"),
            (width: 400.0, height: 1200.0, name: "1:3 (tall)"),
            (width: 600.0, height: 600.0, name: "1:1 (square)"),
        ]
    }

    static func generateEdgeCaseBounds() -> [CGRect] {
        return [
            CGRect(x: 0, y: 0, width: 100, height: 100),  // Very small
            CGRect(x: 0, y: 0, width: 200, height: 150),  // Small
            CGRect(x: 0, y: 0, width: 3000, height: 2000),  // Very large
            CGRect(x: 0, y: 0, width: 50, height: 50),  // Extremely small
        ]
    }

    // MARK: - Validation Helpers

    static func validateContentFitsWithinBounds(
        contentSize: CGSize,
        bounds: CGRect,
        tolerance: CGFloat = 2.0
    ) -> (fitsWidth: Bool, fitsHeight: Bool, widthUtilization: CGFloat, heightUtilization: CGFloat)
    {
        let fitsWidth = contentSize.width <= bounds.width + tolerance
        let fitsHeight = contentSize.height <= bounds.height + tolerance
        let widthUtilization = contentSize.width / bounds.width
        let heightUtilization = contentSize.height / bounds.height

        return (fitsWidth, fitsHeight, widthUtilization, heightUtilization)
    }

    static func validateGridDimensions(
        gridWidth: Int,
        gridHeight: Int,
        fontSize: CGFloat
    ) -> (validWidth: Bool, validHeight: Bool, validFontSize: Bool) {
        let validWidth = gridWidth > 0
        let validHeight = gridHeight > 0
        let validFontSize = fontSize >= 8.0 && fontSize <= 24.0

        return (validWidth, validHeight, validFontSize)
    }

    // MARK: - Performance Testing

    static func measureExecutionTime<T>(_ operation: () throws -> T) rethrows -> (
        result: T, time: TimeInterval
    ) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        return (result, executionTime)
    }
}
