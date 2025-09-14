//
//  ContentView.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var engine = AsciiquariumEngine()
    @State private var isAnimating = false
    @State private var asciiText = ""
    @State private var displayBounds = CGRect(x: 0, y: 0, width: 800, height: 600)
    private let renderer = ASCIIRenderer()

    var body: some View {
        VStack {
            // Title
            Text("Asciiquarium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // ASCII Aquarium Display
            VStack {
                Text("Fish Count: \(engine.entities.count)")
                    .font(.headline)
                    .padding(.bottom, 5)

                // ASCII Display
                GeometryReader { geometry in
                    Text(asciiText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.black)
                        .cornerRadius(8)
                        .clipped()
                        .onAppear {
                            // Always update bounds when geometry appears
                            updateDisplayBounds(geometry.size)
                        }
                        .onChange(of: geometry.size) { _, newSize in
                            updateDisplayBounds(newSize)
                        }
                }
                .frame(minHeight: 200)  // Ensure minimum height for initial display
            }

            // Controls
            HStack {
                Button(isAnimating ? "Stop" : "Start") {
                    if isAnimating {
                        engine.stop()
                        isAnimating = false
                    } else {
                        engine.start()
                        isAnimating = true
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Add Fish") {
                    // Add a new fish to the aquarium
                    let randomX = CGFloat.random(in: 0...engine.sceneWidth)
                    let randomY = CGFloat.random(in: 0...engine.sceneHeight)
                    let fish = AquariumEntity(
                        type: .fish, position: CGPoint(x: randomX, y: randomY), shape: "><>",
                        color: .cyan, speed: 1.0)
                    engine.entities.append(fish)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            // Set up frame callback for real-time updates
            engine.setFrameCallback { bounds in
                // Render the current scene
                let attributedString = renderer.renderScene(entities: engine.entities, in: bounds)
                asciiText = attributedString.string
            }

            // Calculate initial grid dimensions immediately
            let maxCharsPerLine = calculateMaxCharactersPerLine(for: displayBounds)
            let maxLines = calculateMaxLines(for: displayBounds)
            engine.updateSceneDimensions(
                width: maxCharsPerLine,
                height: maxLines,
                fontSize: 12.0
            )
        }
    }

    /// Update display bounds and recalculate optimal grid
    private func updateDisplayBounds(_ size: CGSize) {
        let newBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        print("=== ContentView Bounds Update ===")
        print("New size: \(size)")
        print("New bounds: \(newBounds)")
        print("Previous bounds: \(displayBounds)")
        print("Bounds changed: \(newBounds != displayBounds)")

        // Always update when bounds change
        if newBounds != displayBounds {
            displayBounds = newBounds

            // Calculate how many characters can fit in the available space
            let maxCharsPerLine = calculateMaxCharactersPerLine(for: newBounds)
            let maxLines = calculateMaxLines(for: newBounds)

            print("Max characters per line: \(maxCharsPerLine)")
            print("Max lines: \(maxLines)")

            // Update engine with calculated dimensions
            engine.updateSceneDimensions(
                width: maxCharsPerLine,
                height: maxLines,
                fontSize: 12.0  // Use a fixed font size for now
            )
        }
        print("=================================")
    }

    /// Calculate maximum characters that can fit in the available width
    private func calculateMaxCharactersPerLine(for bounds: CGRect) -> Int {
        let font = NSFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
        let charWidth = calculateCharacterWidth(for: font)
        let maxChars = Int(bounds.width / charWidth)
        print("Character width: \(charWidth), Max chars: \(maxChars)")
        return max(1, maxChars)
    }

    /// Calculate maximum lines that can fit in the available height
    private func calculateMaxLines(for bounds: CGRect) -> Int {
        let font = NSFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
        let lineHeight = calculateLineHeight(for: font)
        let maxLines = Int(bounds.height / lineHeight)
        print("Line height: \(lineHeight), Max lines: \(maxLines)")
        return max(1, maxLines)
    }

    /// Calculate character width for a given font
    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        // Use NSLayoutManager to get the actual space each character takes when rendered
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

    /// Calculate line height for a given font
    private func calculateLineHeight(for font: NSFont) -> CGFloat {
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

        // Validate the result and fallback to font.ascender + font.descender if invalid
        if lineHeight.isFinite && lineHeight > 0 {
            return lineHeight
        } else {
            print(
                "Warning: NSLayoutManager calculation failed, using font.ascender + font.descender")
            return font.ascender + abs(font.descender)
        }
    }
}

#Preview {
    ContentView()
}
