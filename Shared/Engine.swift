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

        // Notify that a new frame is ready - ContentView will handle the actual rendering
        frameCallback?(CGRect.zero)  // ContentView doesn't need bounds for grid-based rendering
    }

    // MARK: - Test Helpers
    #if DEBUG
        /// Advance the engine by one frame duration for testing
        func tickOnceForTests() {
            let fakeDelta = frameInterval
            updateEntities(deltaTime: fakeDelta)
        }
    #endif

    /// Update all entities
    private func updateEntities(deltaTime: CFTimeInterval) {
        // Update existing entities
        for entity in entities {
            entity.update(deltaTime: deltaTime)

            // If entity should die when offscreen, check bounds against the grid and kill if fully out
            if entity.dieOffscreen {
                let bounds = entity.getBounds()
                let left = bounds.x
                let right = bounds.x + (bounds.width - 1)
                let top = bounds.y
                let bottom = bounds.y + (bounds.height - 1)

                let isHorizontallyOut = right < 0 || left >= gridWidth
                let isVerticallyOut = bottom < 0 || top >= gridHeight

                if isHorizontallyOut || isVerticallyOut {
                    entity.kill()
                }
            }
        }

        // Remove dead entities
        entities.removeAll { entity in
            !entity.isAlive
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
        spawnAllFish()  // Use Perl formula for initial fish spawn
    }

    /// Spawn all initial fish using Perl formula: int((height - 9) * width / 350)
    private func spawnAllFish() {
        // Perl: my $screen_size = ($anim->height() - 9) * $anim->width();
        //       my $fish_count = int($screen_size / 350);
        let screenSize = (gridHeight - SpawnConfig.surfaceRegionHeight) * gridWidth
        let fishCount = max(1, screenSize / SpawnConfig.fishDensityDivisor)

        for _ in 0..<fishCount {
            spawnFish()
        }
    }

    private func spawnBottomDecor() {
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Castle at bottom-right
        let castle = EntityFactory.createCastle(at: Position3D(0, 0, 0))
        let castleSize = castle.size
        // Anchor bottom-right: y such that castle's bottom sits on safeBottomY
        let castleY = max(0, layout.safeBottomY - (castleSize.height - 1))
        // Right-align within grid
        let castleX = max(0, gridWidth - castleSize.width)
        castle.position = Position3D(castleX, castleY, Depth.castle)
        entities.append(castle)

        // Seaweed along bottom - random x positions (matching Perl: int(rand($anim->width()-2)) + 1)
        // Perl: my $seaweed_count = int($anim->width() / 15);
        let seaweedCount = max(1, gridWidth / SpawnConfig.seaweedCountDivisor)
        for _ in 0..<seaweedCount {
            // Random x from 1 to width-2 (inclusive), matching Perl behavior
            // Ensure we have at least width 3 for valid range (1 to width-2)
            let maxX = max(1, gridWidth - 2)
            let randomX = Int.random(in: 1...maxX)
            let sea = EntityFactory.createSeaweed(at: Position3D(randomX, 0, Depth.seaweed))
            // Anchor bottom: y so that seaweed bottom sits on safeBottomY
            let h = sea.size.height
            let y = max(0, layout.safeBottomY - (h - 1))
            sea.position = Position3D(randomX, y, Depth.seaweed)
            // Set up death callback to respawn new seaweed (matching Perl: death_cb => \&add_seaweed)
            sea.deathCallback = { [weak self] in
                self?.spawnSeaweed()
            }
            entities.append(sea)
        }
    }

    private func reflowBottomDecorForCurrentGrid() {
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Reflow castle (create if missing)
        if let castleIndex = entities.firstIndex(where: { $0.type == .castle }) {
            let castle = entities[castleIndex]
            let size = castle.size
            let newY = max(0, layout.safeBottomY - (size.height - 1))
            let newX = max(0, gridWidth - size.width)
            castle.position = Position3D(newX, newY, Depth.castle)
        } else {
            let newCastle = EntityFactory.createCastle(at: Position3D(0, 0, Depth.castle))
            let size = newCastle.size
            let newY = max(0, layout.safeBottomY - (size.height - 1))
            let newX = max(0, gridWidth - size.width)
            newCastle.position = Position3D(newX, newY, Depth.castle)
            entities.append(newCastle)
        }

        // Reflow seaweed: adjust count and spacing
        var weeds = entities.filter { $0.type == .seaweed }
        // Perl: my $seaweed_count = int($anim->width() / 15);
        let desiredCount = max(1, gridWidth / SpawnConfig.seaweedCountDivisor)

        if weeds.count < desiredCount {
            // Add more
            let toAdd = desiredCount - weeds.count
            for _ in 0..<toAdd {
                let sea = EntityFactory.createSeaweed(at: Position3D(0, 0, Depth.seaweed))
                // Set up death callback to respawn new seaweed (matching Perl: death_cb => \&add_seaweed)
                sea.deathCallback = { [weak self] in
                    self?.spawnSeaweed()
                }
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

        // Re-position with random x positions (matching Perl: int(rand($anim->width()-2)) + 1)
        // Also ensure all seaweed have death callbacks set for respawn
        for w in weeds {
            // Random x from 1 to width-2 (inclusive), matching Perl behavior
            // Ensure we have at least width 3 for valid range (1 to width-2)
            let maxX = max(1, gridWidth - 2)
            let randomX = Int.random(in: 1...maxX)
            let h = w.size.height
            let y = max(0, layout.safeBottomY - (h - 1))
            w.position = Position3D(randomX, y, Depth.seaweed)
            // Ensure death callback is set for respawn (may have been lost during reflow)
            if w.deathCallback == nil {
                w.deathCallback = { [weak self] in
                    self?.spawnSeaweed()
                }
            }
        }
    }

    /// Spawn a new seaweed (used for respawn on death)
    private func spawnSeaweed() {
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)
        // Random x from 1 to width-2 (inclusive), matching Perl behavior
        let maxX = max(1, gridWidth - 2)
        let randomX = Int.random(in: 1...maxX)
        let sea = EntityFactory.createSeaweed(at: Position3D(randomX, 0, Depth.seaweed))
        // Anchor bottom: y so that seaweed bottom sits on safeBottomY
        let h = sea.size.height
        let y = max(0, layout.safeBottomY - (h - 1))
        sea.position = Position3D(randomX, y, Depth.seaweed)
        // Set up death callback to respawn new seaweed (matching Perl: death_cb => \&add_seaweed)
        sea.deathCallback = { [weak self] in
            self?.spawnSeaweed()
        }
        entities.append(sea)
    }

    /// Spawn a new fish
    private func spawnFish() {
        // Initial random z position. We'll compute x and y after we know fish direction, size, and height
        let initialZ = Int.random(in: Depth.fishStart...Depth.fishEnd)
        let initialPosition = Position3D(0, 0, initialZ)

        // Create fish to know its direction (set randomly in init), width, and height
        let fish = EntityFactory.createFish(at: initialPosition)

        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)
        let fishHeight = max(1, fish.size.height)
        let fishWidth = max(1, fish.size.width)

        // Choose y within the allowed range
        let minY = layout.fishSpawnMinY
        let maxTopY = max(minY, layout.fishSpawnMaxBottomY - (fishHeight - 1))
        let chosenY = Int.random(in: minY...maxTopY)

        // Spawn off-screen based on direction:
        // - Right-moving fish (direction == 1) spawn off the left edge
        // - Left-moving fish (direction == -1) spawn off the right edge
        let spawnX: Int
        if fish.direction > 0 {
            // Moving right: spawn completely off-screen to the left
            spawnX = -fishWidth
        } else {
            // Moving left: spawn completely off-screen to the right
            spawnX = gridWidth
        }

        fish.position = Position3D(spawnX, chosenY, initialZ)
        // Set up death callback to respawn new fish (matching Perl: death_cb => \&add_fish)
        fish.deathCallback = { [weak self] in
            self?.spawnFish()
        }
        entities.append(fish)
    }

}
