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

    // Scene dimensions - will be calculated dynamically
    var sceneWidth: CGFloat = 800
    var sceneHeight: CGFloat = 600
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

    /// Update scene dimensions based on optimal grid calculation
    func updateSceneDimensions(width: Int, height: Int, fontSize: CGFloat) {
        print("=== Engine Scene Dimensions Update ===")
        print("Input: width=\(width), height=\(height), fontSize=\(fontSize)")
        print("Previous: sceneWidth=\(sceneWidth), sceneHeight=\(sceneHeight)")
        print("Previous grid: gridWidth=\(gridWidth), gridHeight=\(gridHeight)")

        self.gridWidth = width
        self.gridHeight = height

        // Calculate pixel dimensions based on font metrics
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let charWidth = FontMetrics.shared.calculateCharacterWidth(for: font)
        let lineHeight = FontMetrics.shared.calculateLineHeight(for: font)

        self.sceneWidth = CGFloat(width) * charWidth
        self.sceneHeight = CGFloat(height) * lineHeight

        print("Calculated: charWidth=\(charWidth), lineHeight=\(lineHeight)")
        print("New: sceneWidth=\(sceneWidth), sceneHeight=\(sceneHeight)")
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

        // Notify that a new frame is ready
        frameCallback?(CGRect(x: 0, y: 0, width: sceneWidth, height: sceneHeight))
    }

    /// Update all entities
    private func updateEntities(deltaTime: CFTimeInterval) {
        let bounds = CGRect(x: 0, y: 0, width: sceneWidth, height: sceneHeight)

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
        let position = Position3D(50, Int.random(in: 0...Int(sceneHeight)), 0)
        let waterline = EntityFactory.createWaterline(at: position)
        entities.append(waterline)

        for _ in 0..<3 {
            spawnFish()
        }
    }

    /// Spawn a new fish
    private func spawnFish() {
        let bounds = CGRect(x: 0, y: 0, width: sceneWidth, height: sceneHeight)
        let position = Position3D(
            Int.random(in: 0...Int(bounds.width)),
            Int.random(in: 0...Int(bounds.height)),
            Int.random(in: 3...20)  // Random depth for fish
        )

        let fish = EntityFactory.createFish(at: position)
        entities.append(fish)
    }

    /// Spawn a new waterline
    private func spawnWaterline() {
    }
}
