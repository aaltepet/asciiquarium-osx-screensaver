//
//  Engine.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation
import SwiftUI

/// Core animation engine for the asciiquarium
class AsciiquariumEngine: ObservableObject {
    @Published var entities: [Entity] = []
    @Published var isRunning = false

    private var animationTimer: Timer?
    private var lastUpdateTime: CFTimeInterval = 0
    private var frameCallback: ((CGRect) -> Void)?

    // Grid dimensions - the only dimensions we need for grid-based coordinates
    var gridWidth: Int = 80
    var gridHeight: Int = 24

    // Animation settings
    private let targetFPS: Double = 30.0
    private let frameInterval: Double = 1.0 / 30.0

    // Spawn settings
    private var lastSpawnTime: CFTimeInterval = 0
    private let spawnInterval: Double = 2.0  // Spawn new fish every 2 seconds

    init() {
        // Initialize with some basic entities for testing
        spawnInitialEntities()
    }

    deinit {
        stop()
    }

    /// Start the animation loop
    func start() {
        guard !isRunning else { return }

        isRunning = true
        lastUpdateTime = CACurrentMediaTime()

        animationTimer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) {
            [weak self] _ in
            self?.updateFrame()
        }
    }

    /// Stop the animation loop
    func stop() {
        guard isRunning else { return }

        isRunning = false
        animationTimer?.invalidate()
        animationTimer = nil
    }

    /// Set callback for frame updates
    func setFrameCallback(_ callback: @escaping (CGRect) -> Void) {
        frameCallback = callback
    }

    /// Update grid dimensions - Engine only manages grid coordinates
    func updateGridDimensions(width: Int, height: Int) {
        print("=== Engine Grid Dimensions Update ===")
        print("Input: width=\(width), height=\(height)")
        print("Previous grid: gridWidth=\(gridWidth), gridHeight=\(gridHeight)")

        self.gridWidth = width
        self.gridHeight = height

        print("New grid: gridWidth=\(gridWidth), gridHeight=\(gridHeight)")
        print("=====================================")

        // Reflow static decor to match new grid size
        reflowBottomDecorForCurrentGrid()
    }

    /// Update animation frame
    private func updateFrame() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        updateEntities(deltaTime: deltaTime)
        spawnNewEntities(currentTime: currentTime)

        // Notify that a new frame is ready - ContentView will handle the actual rendering
        frameCallback?(CGRect.zero)  // ContentView doesn't need bounds for grid-based rendering
    }

    /// Update all entities
    private func updateEntities(deltaTime: CFTimeInterval) {
        // Update existing entities
        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }

        // Remove dead entities
        entities.removeAll { entity in
            !entity.isAlive
        }
    }

    /// Spawn new entities
    private func spawnNewEntities(currentTime: CFTimeInterval) {
        if currentTime - lastSpawnTime >= spawnInterval {
            spawnFish()
            lastSpawnTime = currentTime
        }
    }

    /// Spawn initial entities for testing
    private func spawnInitialEntities() {
        // Create four waterline rows at y=5..8 using explicit (y,z,segmentIndex) tuples
        let waterlineRows: [(y: Int, z: Int, segmentIndex: Int)] = [
            (5, Depth.waterLine3, 0),
            (6, Depth.waterLine2, 1),
            (7, Depth.waterLine1, 2),
            (8, Depth.waterLine0, 3),
        ]
        for row in waterlineRows {
            let pos = Position3D(0, row.y, row.z)
            let wl = EntityFactory.create(
                from: .waterline(position: pos, segmentIndex: row.segmentIndex))
            entities.append(wl)
        }

        spawnBottomDecor()

        for _ in 0..<3 {
            spawnFish()
        }
    }

    private func spawnBottomDecor() {
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Castle at bottom-right
        let castle = EntityFactory.createCastle(at: Position3D(0, 0, 0))
        let castleSize = castle.size
        // Anchor bottom-right: y such that castle's bottom sits on bottomY
        let castleY = max(0, layout.bottomY - (castleSize.height - 1))
        // Right-align within grid
        let castleX = max(0, gridWidth - castleSize.width)
        castle.position = Position3D(castleX, castleY, Depth.castle)
        entities.append(castle)

        // Seaweed along bottom
        let seaweedCount = max(1, gridWidth / 15)
        let step = max(1, gridWidth / seaweedCount)
        var x = 1
        for _ in 0..<seaweedCount {
            let sea = EntityFactory.createSeaweed(at: Position3D(x, 0, Depth.seaweed))
            // Anchor bottom: y so that seaweed bottom sits on bottomY
            let h = sea.size.height
            let y = max(0, layout.bottomY - (h - 1))
            sea.position = Position3D(x, y, Depth.seaweed)
            entities.append(sea)
            x += step
        }
    }

    private func reflowBottomDecorForCurrentGrid() {
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Reflow castle (create if missing)
        if let castleIndex = entities.firstIndex(where: { $0.type == .castle }) {
            let castle = entities[castleIndex]
            let size = castle.size
            let newY = max(0, layout.bottomY - (size.height - 1))
            let newX = max(0, gridWidth - size.width)
            castle.position = Position3D(newX, newY, Depth.castle)
        } else {
            let newCastle = EntityFactory.createCastle(at: Position3D(0, 0, Depth.castle))
            let size = newCastle.size
            let newY = max(0, layout.bottomY - (size.height - 1))
            let newX = max(0, gridWidth - size.width)
            newCastle.position = Position3D(newX, newY, Depth.castle)
            entities.append(newCastle)
        }

        // Reflow seaweed: adjust count and spacing
        var weeds = entities.filter { $0.type == .seaweed }
        let desiredCount = max(1, gridWidth / 15)

        if weeds.count < desiredCount {
            // Add more
            let toAdd = desiredCount - weeds.count
            for _ in 0..<toAdd {
                let sea = EntityFactory.createSeaweed(at: Position3D(0, 0, Depth.seaweed))
                weeds.append(sea)
                entities.append(sea)
            }
        } else if weeds.count > desiredCount {
            // Remove extras (from entities array as well)
            let extras = weeds.count - desiredCount
            let remove = weeds.prefix(extras)
            for w in remove {
                if let idx = entities.firstIndex(where: { $0.id == w.id }) {
                    entities.remove(at: idx)
                }
            }
            weeds.removeFirst(extras)
        }

        // Re-position evenly across width
        let count = max(1, weeds.count)
        let step = max(1, gridWidth / count)
        var x = min(gridWidth - 1, step / 2)
        for w in weeds {
            let h = w.size.height
            let y = max(0, layout.bottomY - (h - 1))
            w.position = Position3D(min(max(0, x), max(0, gridWidth - 1)), y, Depth.seaweed)
            x += step
        }
    }

    /// Spawn a new fish
    private func spawnFish() {
        let position = Position3D(
            Int.random(in: 0..<gridWidth),
            // must be below the waterline
            Int.random(in: 9..<gridHeight),
            Int.random(in: Depth.fishStart...Depth.fishEnd)  // Random depth for fish
        )

        let fish = EntityFactory.create(from: .fish(position: position))
        entities.append(fish)
    }

}
