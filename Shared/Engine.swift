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
    @Published var entities: [AquariumEntity] = []
    @Published var isRunning = false

    private var animationTimer: Timer?
    private var lastUpdateTime: CFTimeInterval = 0
    private var frameCallback: ((CGRect) -> Void)?

    // Scene dimensions
    static let sceneWidth: CGFloat = 800
    static let sceneHeight: CGFloat = 600

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

    /// Update animation frame
    private func updateFrame() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        updateEntities(deltaTime: deltaTime)
        spawnNewEntities(currentTime: currentTime)

        // Notify that a new frame is ready
        frameCallback?(CGRect(x: 0, y: 0, width: Self.sceneWidth, height: Self.sceneHeight))
    }

    /// Update all entities
    private func updateEntities(deltaTime: CFTimeInterval) {
        let bounds = CGRect(x: 0, y: 0, width: Self.sceneWidth, height: Self.sceneHeight)
        let currentTime = Date().timeIntervalSince1970

        // Update existing entities
        for i in 0..<entities.count {
            entities[i].update(deltaTime: deltaTime, bounds: bounds)
        }

        // Remove expired entities
        entities.removeAll { entity in
            entity.isExpired(currentTime: currentTime)
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
        // Spawn a few fish to start
        for _ in 0..<3 {
            spawnFish()
        }
    }

    /// Spawn a new fish
    private func spawnFish() {
        let bounds = CGRect(x: 0, y: 0, width: Self.sceneWidth, height: Self.sceneHeight)
        let position = CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height)
        )

        let fish = AquariumEntity(
            type: .fish,
            position: position,
            shape: "><>",
            color: .blue,
            speed: 1.0
        )

        entities.append(fish)
    }
}
