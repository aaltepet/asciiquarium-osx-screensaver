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
        // Place waterline at row 4 (grid coordinates)
        let waterlinePosition = Position3D(0, 4, 0)
        let waterline = EntityFactory.createWaterline(at: waterlinePosition)
        entities.append(waterline)

        for _ in 0..<3 {
            spawnFish()
        }
    }

    /// Spawn a new fish
    private func spawnFish() {
        let position = Position3D(
            Int.random(in: 0..<gridWidth),
            // must be below the waterline
            Int.random(in: 7..<gridHeight),
            Int.random(in: 3...20)  // Random depth for fish
        )

        let fish = EntityFactory.createFish(at: position)
        entities.append(fish)
    }

    /// Spawn a new waterline
    private func spawnWaterline() {
    }
}
