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
        let charWidth = calculateCharacterWidth(for: font)
        let lineHeight = calculateLineHeight(for: font)

        self.sceneWidth = CGFloat(width) * charWidth
        self.sceneHeight = CGFloat(height) * lineHeight

        print("Calculated: charWidth=\(charWidth), lineHeight=\(lineHeight)")
        print("New: sceneWidth=\(sceneWidth), sceneHeight=\(sceneHeight)")
        print("New grid: gridWidth=\(gridWidth), gridHeight=\(gridHeight)")
        print("=====================================")
    }

    /// Calculate character width for a given font
    private func calculateCharacterWidth(for font: NSFont) -> CGFloat {
        // Use NSLayoutManager to get the actual space each character takes when rendered
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        // Test with multiple characters to get accurate per-character width
        let testString = "MMMMMMMMMMMMMMMM"  // 16 characters
        let attributedString = NSAttributedString(string: testString, attributes: [.font: font])
        textStorage.setAttributedString(attributedString)

        let usedRect = layoutManager.usedRect(for: textContainer)
        let perCharWidth = usedRect.width / CGFloat(testString.count)

        // Validate the result and fallback to font.maximumAdvancement if invalid
        if perCharWidth.isFinite && perCharWidth > 0 {
            return perCharWidth
        } else {
            print("Warning: NSLayoutManager calculation failed, using font.maximumAdvancement")
            return font.maximumAdvancement.width
        }
    }

    /// Calculate line height for a given font
    private func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender - font.descender + font.leading
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
        let bounds = CGRect(x: 0, y: 0, width: sceneWidth, height: sceneHeight)
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
