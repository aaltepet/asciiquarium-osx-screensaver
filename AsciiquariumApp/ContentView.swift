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
                Text("Fish Count: \(engine.entities.count)")
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

            // Calculate initial optimal grid dimensions and font size
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: displayBounds)
            engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

            // Update renderer with the same font size calculated by FontMetrics
            renderer.updateFont(size: optimalGrid.fontSize)
            // Apply exact same font to the SwiftUI Text to avoid wrapping mismatches
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

            // Calculate optimal grid dimensions and font size
            let optimalGrid = FontMetrics.shared.calculateOptimalGridDimensions(for: newBounds)

            print(
                "Optimal grid: width=\(optimalGrid.width), height=\(optimalGrid.height), fontSize=\(optimalGrid.fontSize)"
            )

            // Update engine with new grid dimensions
            engine.updateGridDimensions(width: optimalGrid.width, height: optimalGrid.height)

            // Update renderer with the same font size calculated by FontMetrics
            renderer.updateFont(size: optimalGrid.fontSize)
            // Clear attributed text so next frame uses updated font
            attributedAsciiText = AttributedString("")
        }
        print("=================================")
    }
}

#Preview {
    ContentView()
}
