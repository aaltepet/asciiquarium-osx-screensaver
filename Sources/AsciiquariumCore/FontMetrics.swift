import AppKit
import Foundation

/// Centralized font metrics utility for consistent character width and line height calculations
/// This eliminates duplicate calculation methods across ContentView, ASCIIRenderer, and Engine
public class FontMetrics {

    // MARK: - Singleton
    public static let shared = FontMetrics()

    private init() {}

    // MARK: - Character Width Calculation

    /// Calculate character width for a given font using NSLayoutManager
    /// This is the most accurate method as it measures actual rendered text
    public func calculateCharacterWidth(for font: NSFont) -> CGFloat {
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
    public func calculateLineHeight(for font: NSFont) -> CGFloat {
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
    public func calculateLineHeightFromFontMetrics(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
    }

    // MARK: - Grid Dimension Calculations (Fixed Font Size)

    /// Calculate grid dimensions that fit in the given bounds for a specific font
    public func calculateGridDimensions(for bounds: CGRect, font: NSFont) -> (
        width: Int, height: Int
    ) {
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        guard charWidth.isFinite && charWidth > 0 else {
            print("Error: Invalid character width: \(charWidth)")
            return (width: 80, height: 24)
        }

        guard lineHeight.isFinite && lineHeight > 0 else {
            print("Error: Invalid line height: \(lineHeight)")
            return (width: 80, height: 24)
        }

        let gridWidth = max(1, Int(bounds.width / charWidth))
        let gridHeight = max(1, Int(bounds.height / lineHeight))

        return (width: gridWidth, height: gridHeight)
    }

    // MARK: - Font Size Management

    /// Get the default (fixed) font size used across the app
    public func getDefaultFontSize() -> CGFloat {
        return 16.0
    }

    /// Create a default font using the standard font size
    public func createDefaultFont() -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: getDefaultFontSize(), weight: .regular)
    }

    // MARK: - Utility Methods

    /// Calculate maximum characters that can fit in the available width
    public func calculateMaxCharacters(for bounds: CGRect, font: NSFont) -> Int {
        let charWidth = calculateCharacterWidth(for: font)
        let maxChars = Int(bounds.width / charWidth)
        return max(1, maxChars)
    }

    /// Calculate maximum lines that can fit in the available height
    public func calculateMaxLines(for bounds: CGRect, font: NSFont) -> Int {
        let lineHeight = calculateLineHeight(for: font)
        let maxLines = Int(bounds.height / lineHeight)
        return max(1, maxLines)
    }
}
