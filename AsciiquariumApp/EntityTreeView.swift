//
//  EntityTreeView.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import AsciiquariumCore
import SwiftUI

struct EntityTreeView: View {
    @ObservedObject var engine: AsciiquariumEngine
    @State private var expandedEntities: Set<UUID> = []
    @State private var selectedEntityType: EntityType? = nil

    private var entities: [Entity] {
        engine.entities
    }

    var body: some View {
        // Reference frameUpdateCounter to ensure view updates when entities change
        let _ = engine.frameUpdateCounter

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Entities (\(entities.count))")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                Spacer()

                // Filter by type
                Menu {
                    Button("All Types") {
                        selectedEntityType = nil
                    }
                    ForEach(EntityType.allCases, id: \.self) { type in
                        Button(type.rawValue) {
                            selectedEntityType = type
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .padding(.horizontal)
                }
            }
            .background(Color(NSColor.controlBackgroundColor))

            // Entity list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(filteredEntities, id: \.id) { entity in
                        EntityRowView(
                            entity: entity,
                            frameCounter: engine.frameUpdateCounter,
                            isExpanded: expandedEntities.contains(entity.id),
                            onToggle: {
                                if expandedEntities.contains(entity.id) {
                                    expandedEntities.remove(entity.id)
                                } else {
                                    expandedEntities.insert(entity.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .frame(minWidth: 300, maxWidth: 500, minHeight: 200, maxHeight: 600)
    }

    private var filteredEntities: [Entity] {
        if let selectedType = selectedEntityType {
            return entities.filter { $0.type == selectedType }
        }
        return entities
    }
}

struct EntityRowView: View {
    let entity: Entity
    let frameCounter: Int
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack {
                // Expand/collapse button
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                        .frame(width: 16, height: 16)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                // Entity type icon
                entityIcon(for: entity.type)
                    .frame(width: 16, height: 16)

                // Entity type name
                Text(entity.type.rawValue)
                    .font(.system(size: 12, weight: .medium))

                Spacer()

                // Status indicator
                Circle()
                    .fill(entity.isAlive ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                // Entity ID (shortened)
                Text(String(entity.id.uuidString.prefix(8)))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .background(isExpanded ? Color(NSColor.controlAccentColor).opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }

            // Expanded details
            if isExpanded {
                EntityDetailsView(entity: entity, frameCounter: frameCounter)
                    .padding(.leading, 24)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.textBackgroundColor).opacity(0.5))
            }
        }
    }

    @ViewBuilder
    private func entityIcon(for type: EntityType) -> some View {
        switch type {
        case .fish:
            Image(systemName: "fish")
        case .shark:
            Image(systemName: "triangle.fill")
        case .bubble:
            Image(systemName: "circle.fill")
        case .waterline:
            Image(systemName: "waveform")
        case .castle:
            Image(systemName: "building.2")
        case .seaweed:
            Image(systemName: "leaf")
        case .ship:
            Image(systemName: "sailboat")
        case .whale:
            Image(systemName: "water.waves")
        case .monster:
            Image(systemName: "eye")
        case .bigFish:
            Image(systemName: "fish.fill")
        case .ducks:
            Image(systemName: "bird")
        case .dolphins:
            Image(systemName: "water.waves.slash")
        case .swan:
            Image(systemName: "bird.fill")
        case .splat:
            Image(systemName: "drop.fill")
        case .teeth:
            Image(systemName: "asterisk")
        default:
            Image(systemName: "square.fill")
        }
    }
}

struct EntityDetailsView: View {
    let entity: Entity
    let frameCounter: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Basic info
            DetailRow(label: "Name", value: entity.name)
            DetailRow(label: "ID", value: entity.id.uuidString)
            DetailRow(label: "Type", value: entity.type.rawValue)
            DetailRow(label: "Alive", value: entity.isAlive ? "Yes" : "No")

            Divider()

            // Position
            DetailRow(
                label: "Position",
                value: "(\(entity.position.x), \(entity.position.y), \(entity.position.z))"
            )

            // Size
            DetailRow(
                label: "Size",
                value: "\(entity.size.width) × \(entity.size.height)"
            )

            // Bounds
            let bounds = entity.getBounds()
            DetailRow(
                label: "Bounds",
                value: "x:\(bounds.x) y:\(bounds.y) w:\(bounds.width) h:\(bounds.height)"
            )

            Divider()

            // Visual properties
            DetailRow(label: "Color", value: colorName(for: entity.defaultColor))
            if let transparentChar = entity.transparentChar {
                DetailRow(label: "Transparent", value: String(transparentChar))
            }
            DetailRow(label: "Auto Transparent", value: entity.autoTransparent ? "Yes" : "No")

            Divider()

            // Behavioral properties
            DetailRow(label: "Physical", value: entity.isPhysical ? "Yes" : "No")
            DetailRow(label: "Die Offscreen", value: entity.dieOffscreen ? "Yes" : "No")
            if let dieTime = entity.dieTime {
                DetailRow(label: "Die Time", value: String(format: "%.2f", dieTime))
            }
            if let dieFrame = entity.dieFrame {
                DetailRow(label: "Die Frame", value: "\(dieFrame)")
            }
            DetailRow(
                label: "Has Collision Handler", value: entity.collisionHandler != nil ? "Yes" : "No"
            )
            DetailRow(
                label: "Has Death Callback", value: entity.deathCallback != nil ? "Yes" : "No")
            DetailRow(
                label: "Has Spawn Callback", value: entity.spawnCallback != nil ? "Yes" : "No")

            // Layout properties
            if entity.isFullWidth || entity.isFullHeight {
                Divider()
                DetailRow(label: "Full Width", value: entity.isFullWidth ? "Yes" : "No")
                DetailRow(label: "Full Height", value: entity.isFullHeight ? "Yes" : "No")
            }

            // Shape preview (first few lines)
            if !entity.shape.isEmpty {
                Divider()
                Text("Shape Preview:")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                ForEach(Array(entity.shape.prefix(3).enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                if entity.shape.count > 3 {
                    Text("... (\(entity.shape.count - 3) more lines)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.system(size: 10))
        .id("\(entity.id)-\(frameCounter)")  // Force re-evaluation when frameCounter changes
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .trailing)
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Helper Functions
extension EntityDetailsView {
    func colorName(for color: ColorCode) -> String {
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
    EntityTreeView(engine: AsciiquariumEngine())
}
