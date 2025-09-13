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
                Text(asciiText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.cyan)
                    .frame(
                        width: engine.sceneWidth,
                        height: engine.sceneHeight, alignment: .topLeading
                    )
                    .background(Color.black)
                    .cornerRadius(8)
                    .clipped()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    updateDisplayBounds(geometry.size)
                                }
                                .onChange(of: geometry.size) { _, newSize in
                                    updateDisplayBounds(newSize)
                                }
                        }
                    )
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
        }
    }

    /// Update display bounds and recalculate optimal grid
    private func updateDisplayBounds(_ size: CGSize) {
        let newBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Only update if bounds actually changed
        if newBounds != displayBounds {
            displayBounds = newBounds

            // Calculate optimal grid dimensions
            let optimalGrid = renderer.calculateOptimalGridDimensions(for: newBounds)

            // Update engine with new dimensions
            engine.updateSceneDimensions(
                width: optimalGrid.width,
                height: optimalGrid.height,
                fontSize: optimalGrid.fontSize
            )
        }
    }
}

#Preview {
    ContentView()
}
