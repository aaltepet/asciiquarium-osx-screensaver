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
    @State private var attributedAsciiText = AttributedString("")
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
                Text("Fish Count: \(engine.entities.filter { $0.type == .fish }.count)")
                    .font(.headline)
                    .padding(.bottom, 5)

                // ASCII Display
                GeometryReader { geometry in
                    Text(attributedAsciiText)
                        .kerning(0)
                        .lineSpacing(0)
                        .fixedSize(horizontal: true, vertical: false)
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

                Button("Step Forward") {
                    engine.stepForward()
                }
                .buttonStyle(.bordered)
                .disabled(isAnimating)

                Button("Restart") {
                    engine.restart()
                }
                .buttonStyle(.bordered)

                Button("Add Fish") {
                    // Add a new fish to the aquarium using grid coordinates
                    let randomX = Int.random(in: 0..<engine.gridWidth)
                    // must be below the waterline
                    let randomY = Int.random(in: 7..<engine.gridHeight)
                    let randomZ = Int.random(in: 3...20)
                    let fish = EntityFactory.createFish(at: Position3D(randomX, randomY, randomZ))
                    engine.entities.append(fish)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            // Set up frame callback for real-time updates
            engine.setFrameCallback { bounds in
                // Render the current scene using grid coordinates
                let attributedString = renderer.renderScene(
                    entities: engine.entities, gridWidth: engine.gridWidth,
                    gridHeight: engine.gridHeight)
                asciiText = attributedString.string
                attributedAsciiText = AttributedString(attributedString)
            }

            // Use fixed font size and calculate grid based on it
            let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
            let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
            let dims = FontMetrics.shared.calculateGridDimensions(
                for: displayBounds, font: fixedFont)
            engine.updateGridDimensions(width: dims.width, height: dims.height)

            // Ensure renderer uses the same fixed font size
            renderer.updateFont(size: fixedFontSize)
            attributedAsciiText = AttributedString("")
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

            // Recalculate grid using fixed font size
            let fixedFontSize = FontMetrics.shared.getDefaultFontSize()
            let fixedFont = NSFont.monospacedSystemFont(ofSize: fixedFontSize, weight: .regular)
            let dims = FontMetrics.shared.calculateGridDimensions(for: newBounds, font: fixedFont)

            print("Fixed font size: \(fixedFontSize)")
            print("Grid dims: width=\(dims.width), height=\(dims.height)")

            engine.updateGridDimensions(width: dims.width, height: dims.height)

            // Ensure renderer uses the same fixed font size
            renderer.updateFont(size: fixedFontSize)
            attributedAsciiText = AttributedString("")
        }
        print("=================================")
    }
}

#Preview {
    ContentView()
}
