import AppKit
import Foundation

/// Centralized font metrics utility for consistent character width and line height calculations
/// This eliminates duplicate calculation methods across ContentView, ASCIIRenderer, and Engine
class FontMetrics {

    // MARK: - Singleton
    static let shared = FontMetrics()

    private init() {}

    // MARK: - Character Width Calculation

    /// Calculate character width for a given font using NSLayoutManager
    /// This is the most accurate method as it measures actual rendered text
    func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        // Test with multiple characters to get accurate per-character width
        let testString = "MMMMMMMMMMMMMMMM"  // 16 characters
        let attributedString = NSAttributedString(string: testString, attributes: [.font: font])
        textStorage.setAttributedString(attributedString)

        let usedRect = layoutManager.usedRect(for: textContainer)
        let perCharWidth = usedRect.width / CGFloat(testString.count)

        // Validate the result and fallback to font.maximumAdvancement if invalid
        if perCharWidth.isFinite && perCharWidth > 0 {
            return perCharWidth
        } else {
            print("Warning: NSLayoutManager calculation failed, using font.maximumAdvancement")
            return font.maximumAdvancement.width
        }
    }

    // MARK: - Line Height Calculation

    /// Calculate line height for a given font using NSLayoutManager
    /// This is more accurate than using font metrics directly as it measures actual rendered text
    func calculateLineHeight(for font: NSFont) -> CGFloat {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        let testString = "M\nM"  // Two lines
        let attributedString = NSAttributedString(string: testString, attributes: [.font: font])
        textStorage.setAttributedString(attributedString)

        let usedRect = layoutManager.usedRect(for: textContainer)
        let lineHeight = usedRect.height / 2.0  // Divide by 2 since we have 2 lines

        // Validate the result and fallback to font metrics if invalid
        if lineHeight.isFinite && lineHeight > 0 {
            return lineHeight
        } else {
            print("Warning: NSLayoutManager line height calculation failed, using font metrics")
            return font.ascender - font.descender + font.leading
        }
    }

    // MARK: - Alternative Line Height Calculation

    /// Calculate line height using font metrics (fallback method)
    /// This is faster but less accurate than NSLayoutManager method
    func calculateLineHeightFromFontMetrics(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    // MARK: - Grid Dimension Calculations

    /// Calculate optimal grid dimensions that fit perfectly in the given bounds
    /// This consolidates the grid calculation logic from ASCIIRenderer
    func calculateOptimalGridDimensions(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        // Step 1: Find the optimal font size based on height utilization
        var bestFontSize: CGFloat = 8.0
        var bestHeightUtilization: CGFloat = 0.0

        // Try different font sizes to maximize height utilization
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

        // Validate character width and line height
        guard charWidth.isFinite && charWidth > 0 else {
            print("Error: Invalid character width: \(charWidth)")
            return (width: 80, height: 24, fontSize: bestFontSize)
        }

        guard lineHeight.isFinite && lineHeight > 0 else {
            print("Error: Invalid line height: \(lineHeight)")
            return (width: 80, height: 24, fontSize: bestFontSize)
        }

        // Calculate grid dimensions
        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        // Ensure minimum grid size
        let finalWidth = max(1, gridWidth)
        let finalHeight = max(1, gridHeight)

        print("FontMetrics: Optimal grid dimensions calculated")
        print("  Font size: \(bestFontSize)")
        print("  Character width: \(charWidth)")
        print("  Line height: \(lineHeight)")
        print("  Grid: \(finalWidth) x \(finalHeight)")
        print("  Bounds: \(bounds.width) x \(bounds.height)")

        return (width: finalWidth, height: finalHeight, fontSize: bestFontSize)
    }

    // MARK: - Utility Methods

    /// Calculate maximum characters that can fit in the available width
    func calculateMaxCharacters(for bounds: CGRect, font: NSFont) -> Int {
        let charWidth = calculateCharacterWidth(for: font)
        let maxChars = Int(bounds.width / charWidth)
        return max(1, maxChars)
    }

    /// Calculate maximum lines that can fit in the available height
    func calculateMaxLines(for bounds: CGRect, font: NSFont) -> Int {
        let lineHeight = calculateLineHeight(for: font)
        let maxLines = Int(bounds.height / lineHeight)
        return max(1, maxLines)
    }
}
