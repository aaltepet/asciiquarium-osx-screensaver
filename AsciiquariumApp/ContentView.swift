//
//  ContentView.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import AsciiquariumCore
import SwiftUI

struct ContentView: View {
    @StateObject private var engine = AsciiquariumEngine()
    @State private var isAnimating = false
    @State private var asciiText = ""
    @State private var attributedAsciiText = AttributedString("")
    @State private var displayBounds = CGRect(x: 0, y: 0, width: 800, height: 600)
    @State private var showEntityViewer = false
    private let renderer = ASCIIRenderer()

    var body: some View {
        HSplitView {
            // Main aquarium view
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
                            .frame(
                                maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading
                            )
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
                        let fish = EntityFactory.createFish(
                            at: Position3D(randomX, randomY, randomZ))
                        engine.entities.append(fish)
                    }
                    .buttonStyle(.bordered)

                    Button("Print Entities") {
                        printEntitiesToConsole()
                    }
                    .buttonStyle(.bordered)

                    Button(showEntityViewer ? "Hide Entities" : "Show Entities") {
                        showEntityViewer.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .frame(minWidth: 400)

            // Entity viewer panel
            if showEntityViewer {
                EntityTreeView(engine: engine)
                    .frame(minWidth: 300, maxWidth: 500)
            }
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

    /// Print all entities to console with detailed information
    private func printEntitiesToConsole() {
        print("\n" + String(repeating: "=", count: 80))
        print("ENTITY LIST - Total: \(engine.entities.count)")
        print(String(repeating: "=", count: 80))

        // Group by type
        let grouped = Dictionary(grouping: engine.entities) { $0.type }
        let sortedTypes = grouped.keys.sorted { $0.rawValue < $1.rawValue }

        for entityType in sortedTypes {
            let entitiesOfType = grouped[entityType] ?? []
            print("\n[\(entityType.rawValue.uppercased())] - Count: \(entitiesOfType.count)")
            print(String(repeating: "-", count: 80))

            for (index, entity) in entitiesOfType.enumerated() {
                print("\n  \(index + 1). \(entity.name)")
                print("     ID: \(entity.id.uuidString)")
                print(
                    "     Position: (\(entity.position.x), \(entity.position.y), \(entity.position.z))"
                )
                print("     Size: \(entity.size.width) × \(entity.size.height)")
                let bounds = entity.getBounds()
                print(
                    "     Bounds: x:\(bounds.x) y:\(bounds.y) w:\(bounds.width) h:\(bounds.height)")
                print("     Alive: \(entity.isAlive ? "✓" : "✗")")
                print("     Physical: \(entity.isPhysical ? "Yes" : "No")")
                print("     Die Offscreen: \(entity.dieOffscreen ? "Yes" : "No")")
                print("     Color: \(colorName(for: entity.defaultColor))")

                if let dieTime = entity.dieTime {
                    print("     Die Time: \(String(format: "%.2f", dieTime))")
                }
                if let dieFrame = entity.dieFrame {
                    print("     Die Frame: \(dieFrame)")
                }

                if entity.collisionHandler != nil {
                    print("     Has Collision Handler: Yes")
                }
                if entity.deathCallback != nil {
                    print("     Has Death Callback: Yes")
                }
                if entity.spawnCallback != nil {
                    print("     Has Spawn Callback: Yes")
                }

                if entity.isFullWidth || entity.isFullHeight {
                    print(
                        "     Full Width: \(entity.isFullWidth), Full Height: \(entity.isFullHeight)"
                    )
                }

                // Show shape preview (first 3 lines)
                if !entity.shape.isEmpty {
                    print("     Shape Preview:")
                    for (lineIndex, line) in entity.shape.prefix(3).enumerated() {
                        let preview = line.count > 60 ? String(line.prefix(60)) + "..." : line
                        print("       [\(lineIndex)]: \(preview)")
                    }
                    if entity.shape.count > 3 {
                        print("       ... (\(entity.shape.count - 3) more lines)")
                    }
                }
            }
        }

        print("\n" + String(repeating: "=", count: 80))
        print("END OF ENTITY LIST")
        print(String(repeating: "=", count: 80) + "\n")
    }

    /// Get readable color name for ColorCode
    private func colorName(for color: ColorCode) -> String {
        switch color {
        case .cyan: return "Cyan"
        case .cyanBright: return "Cyan (Bright)"
        case .red: return "Red"
        case .redBright: return "Red (Bright)"
        case .yellow: return "Yellow"
        case .yellowBright: return "Yellow (Bright)"
        case .blue: return "Blue"
        case .blueBright: return "Blue (Bright)"
        case .green: return "Green"
        case .greenBright: return "Green (Bright)"
        case .magenta: return "Magenta"
        case .magentaBright: return "Magenta (Bright)"
        case .white: return "White"
        case .whiteBright: return "White (Bright)"
        case .black: return "Black"
        case .blackBright: return "Black (Bright)"
        }
    }
}

#Preview {
    ContentView()
}
