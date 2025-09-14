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
    /// This uses an improved algorithm that optimizes both width and height utilization
    func calculateOptimalGridDimensions(for bounds: CGRect) -> (
        width: Int, height: Int, fontSize: CGFloat
    ) {
        // Step 1: Use binary search to find optimal font size
        let result = findOptimalFontSizeBinarySearch(for: bounds)

        // Step 2: Calculate final grid dimensions
        let optimalFont = NSFont.monospacedSystemFont(ofSize: result.fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: optimalFont)
        let lineHeight = calculateLineHeight(for: optimalFont)

        // Validate character width and line height
        guard charWidth.isFinite && charWidth > 0 else {
            print("Error: Invalid character width: \(charWidth)")
            return (width: 80, height: 24, fontSize: result.fontSize)
        }

        guard lineHeight.isFinite && lineHeight > 0 else {
            print("Error: Invalid line height: \(lineHeight)")
            return (width: 80, height: 24, fontSize: result.fontSize)
        }

        // Calculate grid dimensions
        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        // Ensure minimum grid size
        let finalWidth = max(1, gridWidth)
        let finalHeight = max(1, gridHeight)

        print("FontMetrics: Optimal grid dimensions calculated")
        print("  Font size: \(result.fontSize)")
        print("  Character width: \(charWidth)")
        print("  Line height: \(lineHeight)")
        print("  Grid: \(finalWidth) x \(finalHeight)")
        print("  Bounds: \(bounds.width) x \(bounds.height)")
        print("  Width utilization: \(result.widthUtilization * 100)%")
        print("  Height utilization: \(result.heightUtilization * 100)%")
        print("  Combined score: \(result.combinedScore)")

        return (width: finalWidth, height: finalHeight, fontSize: result.fontSize)
    }

    // MARK: - Optimized Font Size Calculation

    /// Result of font size optimization
    private struct FontOptimizationResult {
        let fontSize: CGFloat
        let widthUtilization: CGFloat
        let heightUtilization: CGFloat
        let combinedScore: CGFloat
    }

    /// Find optimal font size using binary search for efficiency
    private func findOptimalFontSizeBinarySearch(for bounds: CGRect) -> FontOptimizationResult {
        let minFontSize: CGFloat = 8.0
        let maxFontSize: CGFloat = 24.0
        let tolerance: CGFloat = 0.1

        var low = minFontSize
        var high = maxFontSize
        var bestResult = FontOptimizationResult(
            fontSize: minFontSize, widthUtilization: 0, heightUtilization: 0, combinedScore: 0)

        // Binary search for optimal font size
        while high - low > tolerance {
            let mid1 = low + (high - low) / 3
            let mid2 = high - (high - low) / 3

            let result1 = evaluateFontSize(mid1, for: bounds)
            let result2 = evaluateFontSize(mid2, for: bounds)

            if result1.combinedScore > result2.combinedScore {
                high = mid2
                if result1.combinedScore > bestResult.combinedScore {
                    bestResult = result1
                }
            } else {
                low = mid1
                if result2.combinedScore > bestResult.combinedScore {
                    bestResult = result2
                }
            }
        }

        return bestResult
    }

    /// Evaluate a specific font size and return utilization metrics
    private func evaluateFontSize(_ fontSize: CGFloat, for bounds: CGRect) -> FontOptimizationResult
    {
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        // Calculate grid dimensions
        let gridWidth = Int(bounds.width / charWidth)
        let gridHeight = Int(bounds.height / lineHeight)

        guard gridWidth > 0 && gridHeight > 0 else {
            return FontOptimizationResult(
                fontSize: fontSize, widthUtilization: 0, heightUtilization: 0, combinedScore: 0)
        }

        // Calculate utilization percentages
        let usedWidth = CGFloat(gridWidth) * charWidth
        let usedHeight = CGFloat(gridHeight) * lineHeight
        let widthUtilization = usedWidth / bounds.width
        let heightUtilization = usedHeight / bounds.height

        // Calculate combined score (weighted average favoring higher utilization)
        // Use geometric mean to penalize cases where one dimension is very poorly utilized
        let combinedScore =
            sqrt(widthUtilization * heightUtilization) * (widthUtilization + heightUtilization) / 2

        return FontOptimizationResult(
            fontSize: fontSize,
            widthUtilization: widthUtilization,
            heightUtilization: heightUtilization,
            combinedScore: combinedScore
        )
    }

    // MARK: - Font Size Management

    /// Get the default font size for initial rendering
    /// This provides a consistent starting point before optimal sizing is calculated
    func getDefaultFontSize() -> CGFloat {
        return 12.0  // Reasonable default that works well for most cases
    }

    /// Create a default font using the standard font size
    func createDefaultFont() -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: getDefaultFontSize(), weight: .regular)
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
