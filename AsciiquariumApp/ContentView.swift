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
                ScrollView {
                    Text(asciiText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .frame(width: AsciiquariumEngine.sceneWidth, height: AsciiquariumEngine.sceneHeight)
                .background(Color.black)
                .cornerRadius(8)
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
                    let randomX = CGFloat.random(in: 0...AsciiquariumEngine.sceneWidth)
                    let randomY = CGFloat.random(in: 0...AsciiquariumEngine.sceneHeight)
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
}

#Preview {
    ContentView()
}
