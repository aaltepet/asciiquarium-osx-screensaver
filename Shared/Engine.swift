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

    // Grid dimensions can change when the controller (e.g. ContentView or screensaver) is resized.
    func updateGridDimensions(width: Int, height: Int) {
        self.gridWidth = width
        self.gridHeight = height
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

    /// Step forward one tick (one frame duration)
    /// This allows manual stepping through the animation when paused
    func stepForward() {
        updateEntities(deltaTime: frameInterval)

        // Notify that a new frame is ready - ContentView will handle the actual rendering
        frameCallback?(CGRect.zero)
    }

    /// Restart the simulation by clearing all entities and respawning initial entities
    func restart() {
        // Clear all existing entities
        entities.removeAll()

        // Respawn initial entities
        spawnInitialEntities()

        // Notify that a new frame is ready - ContentView will handle the actual rendering
        frameCallback?(CGRect.zero)
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
        // Set spawn callback on all entities before updating
        // This allows entities to spawn new entities during their update
        let spawnCallback = createSpawnCallback()

        // Collect dead entity IDs to remove after iteration
        // This prevents issues when death callbacks spawn new entities during iteration
        var deadEntityIds: [UUID] = []

        // Track initial count to detect newly spawned entities
        let initialCount = entities.count

        // Update existing entities
        for i in 0..<initialCount {
            let entity = entities[i]

            // Ensure spawn callback is set (in case entity was created before callback was available)
            entity.spawnCallback = spawnCallback
            entity.update(deltaTime: deltaTime)

            // Check for collisions after position update
            // Only check collisions for physical entities that are still alive
            if entity.isPhysical && entity.isAlive {
                let collisions = entity.checkCollisions(with: entities)
                if !collisions.isEmpty, let handler = entity.collisionHandler {
                    // Call collision handler with entity and list of colliding entities
                    handler(entity, collisions)
                }
            }

            // If entity should die when offscreen, check bounds against the grid and kill if fully out
            if entity.dieOffscreen && entity.isAlive {
                let bounds = entity.getBounds()
                let left = bounds.x
                let right = bounds.x + bounds.width - 1
                let top = bounds.y
                let bottom = bounds.y + bounds.height - 1

                let isFullyOffLeft = right < 0
                let isFullyOffRight = left >= gridWidth
                let isHorizontallyOut = isFullyOffLeft || isFullyOffRight
                let isVerticallyOut = bottom < 0 || top >= gridHeight

                if isHorizontallyOut || isVerticallyOut {
                    entity.kill()
                }
            }

            // Collect all dead entities for removal (regardless of how they died)
            // This catches entities killed by collisions, offscreen, dieTime, dieFrame, etc.
            if !entity.isAlive {
                deadEntityIds.append(entity.id)
            }
        }

        // Process any newly spawned entities (from death callbacks) in the same frame
        // This ensures they get updated and can move into view
        if entities.count > initialCount {
            for i in initialCount..<entities.count {
                let newEntity = entities[i]
                newEntity.spawnCallback = spawnCallback
                newEntity.update(deltaTime: deltaTime)
                // Don't check offscreen for newly spawned entities in their first frame
                // They spawn offscreen by design and need a chance to move into view
                // They'll be checked for offscreen in the next frame
            }
        }

        // Remove dead entities after iteration completes
        // This ensures death callbacks that spawn new entities work correctly
        entities.removeAll { entity in
            deadEntityIds.contains(entity.id)
        }
    }

    /// Create a spawn callback closure that can be used by entities
    private func createSpawnCallback() -> (Entity) -> Void {
        return { [weak self] newEntity in
            self?.entities.append(newEntity)
            // Set spawn callback on newly spawned entity so it can also spawn things
            newEntity.spawnCallback = self?.createSpawnCallback()
        }
    }

    /// Spawn initial entities for testing
    private func spawnInitialEntities() {
        // Create four waterline rows at y=5..8 using explicit (y,z,segmentIndex) tuples
        /*let waterlineRows: [(y: Int, z: Int, segmentIndex: Int)] = [
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
        }*/

        //spawnBottomDecor()
        //spawnAllFish()
        // Spawn one random object at startup (matching Perl: random_object(undef, $anim))
        spawnRandomObject()
    }

    /// Spawn a random object (matching Perl: random_object)
    /// Perl has 8 random object types: ship, whale, monster, big_fish, shark, fishhook, swan, ducks, dolphins
    /// Each has 1/8 chance of being selected
    private func spawnRandomObject() {
        // Perl: my $sub = int(rand(scalar(@random_objects)));
        // There are 8 random object types, so each has 1/8 chance
        let randomValue = Double.random(in: 0...1)
        let slot = randomValue * 8.0

        spawnDolphins()
        //spawnMonster()
        return
        /*            if slot < 1.0
                {
                    spawnShip()  // 0.0 - 1.0 (1/8)
                } else if slot < 2.0 {
                    spawnWhale()  // 1.0 - 2.0 (1/8)
                } else if slot < 3.0 {
                    spawnMonster()  // 2.0 - 3.0 (1/8)
                } else if slot < 4.0 {
                    spawnBigFish()  // 3.0 - 4.0 (1/8)
                } else if slot < 5.0 {
                    spawnShip()  // 4.0 - 5.0 (1/8)
                } else if slot < 6.0 {
                    // spawnFishhook()  // 5.0 - 6.0 (1/8) - not yet implemented
                    spawnWhale()  // Fallback to whale for now
                } else if slot < 7.0 {
                    spawnSwan()  // 6.0 - 7.0 (1/8)
                } else if slot < 8.0 {
                    spawnDucks()  // 7.0 - 8.0 (1/8)
                } else {
                    spawnDolphins()  // 8.0 (1/8)
                }*/
    }

    /// Spawn all initial fish using Perl formula: int((height - 9) * width / 350)
    private func spawnAllFish() {
        // Perl: my $screen_size = ($anim->height() - 9) * $anim->width();
        //       my $fish_count = int($screen_size / 350);
        let screenSize = (gridHeight - SpawnConfig.surfaceRegionHeight) * gridWidth
        let fishCount = max(1, screenSize / SpawnConfig.fishDensityDivisor)

        /*        for _ in 0..<fishCount {
                    spawnFish()
                }*/
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
        // Set spawn callback so fish can spawn bubbles
        fish.spawnCallback = createSpawnCallback()
        entities.append(fish)
    }

    /// Spawn a new shark (matching Perl: add_shark)
    private func spawnShark() {
        // Spawn y position: int(rand($anim->height() - (10 + 9))) + 9
        // This spawns between y=9 and y=height-10 (below surface region)
        let minY = 9
        let maxY = max(minY, gridHeight - 10)
        let spawnY = Int.random(in: minY...maxY)

        // Create shark (direction is randomized in SharkEntity.init)
        let shark = EntityFactory.createShark(at: Position3D(0, spawnY, Depth.shark))
        let sharkWidth = shark.size.width

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -53
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if shark.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -sharkWidth
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth
        }

        shark.position = Position3D(spawnX, spawnY, Depth.shark)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        // Perl has 8 random object types, so shark has 1/8 chance of respawning
        shark.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        shark.spawnCallback = createSpawnCallback()
        entities.append(shark)
    }

    /// Spawn a new ship (matching Perl: add_ship)
    private func spawnShip() {
        // Perl: position => [ $x, 0, $depth{'water_gap1'} ]
        // Ship spawns at y=0 (surface) at water_gap1 depth
        // Create ship (direction is randomized in ShipEntity.init)
        let ship = EntityFactory.createShip(at: Position3D(0, 0, Depth.waterGap1))
        let shipWidth = ship.size.width

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -24
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if ship.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -shipWidth
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth
        }

        ship.position = Position3D(spawnX, 0, Depth.waterGap1)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        ship.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        ship.spawnCallback = createSpawnCallback()
        entities.append(ship)
    }

    /// Spawn a new whale (matching Perl: add_whale)
    private func spawnWhale() {
        // Perl: position => [ $x, 0, $depth{'water_gap2'} ]
        // Whale spawns at y=0 (surface) at water_gap2 depth
        // Create whale (direction is randomized in WhaleEntity.init)
        let whale = EntityFactory.createWhale(at: Position3D(0, 0, Depth.waterGap2))
        let whaleWidth = whale.size.width

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -18
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if whale.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -whaleWidth
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth
        }

        whale.position = Position3D(spawnX, 0, Depth.waterGap2)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        whale.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        whale.spawnCallback = createSpawnCallback()
        entities.append(whale)
    }

    /// Spawn a new monster (matching Perl: add_monster)
    private func spawnMonster() {
        // Perl: position => [ $x, 2, $depth{'water_gap2'} ]
        // Monster spawns at y=2 (surface region) at water_gap2 depth
        // Create monster (direction is randomized in MonsterEntity.init)
        let monster = EntityFactory.createMonster(at: Position3D(0, 2, Depth.waterGap2))
        let monsterWidth = monster.size.width

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -64
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if monster.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -monsterWidth
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth
        }

        monster.position = Position3D(spawnX, 2, Depth.waterGap2)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        monster.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        monster.spawnCallback = createSpawnCallback()
        entities.append(monster)
    }

    /// Spawn a new swan (matching Perl: add_swan)
    private func spawnSwan() {
        // Perl: position => [ $x, 1, $depth{'water_gap3'} ]
        // Swan spawns at y=1 (surface) at water_gap3 depth
        // Create swan (direction is randomized in SwanEntity.init)
        let swan = EntityFactory.createSwan(at: Position3D(0, 1, Depth.waterGap3))

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -10
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if swan.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -10
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth - 2
        }

        swan.position = Position3D(spawnX, 1, Depth.waterGap3)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        swan.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        swan.spawnCallback = createSpawnCallback()
        entities.append(swan)
    }

    /// Spawn a new ducks (matching Perl: add_ducks)
    private func spawnDucks() {
        // Perl: position => [ $x, 5, $depth{'water_gap3'} ]
        // Ducks spawn at y=5 (surface) at water_gap3 depth
        // However, since ducks span rows 5-7 and waterlines at y=6 (depth 4) and y=7 (depth 6)
        // would overwrite them, we need to use a higher depth to render ducks on top
        // Using water_gap1 (depth 7) ensures ducks render above all waterlines
        // Create ducks (direction is randomized in DucksEntity.init)
        let ducks = EntityFactory.createDucks(at: Position3D(0, 5, Depth.waterGap1))

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -30
        // Left: $x = $anim->width()-2
        let spawnX: Int
        if ducks.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -30
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth - 2
        }

        ducks.position = Position3D(spawnX, 5, Depth.waterGap1)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        ducks.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        ducks.spawnCallback = createSpawnCallback()
        entities.append(ducks)
    }

    /// Spawn a new big fish (matching Perl: add_big_fish)
    private func spawnBigFish() {
        // Perl: position => [ $x, $y, $depth{'shark'} ]
        // Big fish spawns at random y between max_height (9) and min_height (height - 15)
        // at shark depth (depth 2)
        let maxHeight = 9
        let minHeight = max(maxHeight, gridHeight - 15)
        let spawnY = Int.random(in: maxHeight...minHeight)

        // Create big fish (direction is randomized in BigFishEntity.init)
        let bigFish = EntityFactory.createBigFish(at: Position3D(0, spawnY, Depth.shark))

        // Spawn off-screen based on direction - matching Perl:
        // Right: $x = -34
        // Left: $x = $anim->width()-1
        let spawnX: Int
        if bigFish.direction > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -34
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth - 1
        }

        bigFish.position = Position3D(spawnX, spawnY, Depth.shark)

        // Set up death callback to spawn random object (matching Perl: death_cb => \&random_object)
        bigFish.deathCallback = { [weak self] in
            self?.spawnRandomObject()
        }

        bigFish.spawnCallback = createSpawnCallback()
        entities.append(bigFish)
    }

    /// Spawn a group of 3 dolphins (matching Perl: add_dolphins)
    private func spawnDolphins() {
        // Perl: creates 3 dolphins that follow the same path with different delays
        let randomDir = 1  //Bool.random() ? 1 : -1
        let speed = 1.0
        let distance = 15  // How far apart the dolphins are

        // Build the path: 14 up, 2 glide, 14 down, 6 glide
        // Path steps: [speed, dx, dy, dz]
        var path: [[Double]] = []

        // 14 up moves: [speed, dx, -0.5, 0.5]
        for _ in 1...14 {
            path.append([speed, Double(randomDir), -0.5, 0.5])
        }

        // 2 glides: [speed, dx, 0, 0.5]
        for _ in 1...2 {
            path.append([speed, Double(randomDir), 0.0, 0.5])
        }

        // 14 down moves: [speed, dx, 0.5, 0.5]
        for _ in 1...14 {
            path.append([speed, Double(randomDir), 0.5, 0.5])
        }

        // 6 glides: [speed, dx, 0, 0.5]
        for _ in 1...6 {
            path.append([speed, Double(randomDir), 0.0, 0.5])
        }

        // Determine spawn X position
        let spawnX: Int
        if randomDir > 0 {
            // Moving right: spawn off-screen to the left
            spawnX = -13
        } else {
            // Moving left: spawn off-screen to the right
            spawnX = gridWidth - 2
        }

        // Calculate starting y positions based on path offset
        // All dolphins should follow the same vertical range, just offset in time
        // Path: 14 up (-0.5 each), 2 glide (0), 14 down (+0.5 each), 6 glide (0)
        // Base dolphin3 starts at y=8 with offset 0 (step 0)
        // We need to calculate where each dolphin should be based on their path offset

        // Calculate cumulative y position for each path step
        // Step 0: y = 8 (base starting position for dolphin3)
        // For each step, add the dy value to get the y position
        func calculateYAtStep(_ step: Int, baseY: Double) -> Double {
            var y = baseY
            for i in 0..<step {
                if i < path.count {
                    let stepData = path[i]
                    if stepData.count >= 3 {
                        let dy = stepData[2]  // Vertical movement per step
                        y += dy
                    }
                }
            }
            return y
        }

        let baseY: Double = 8.0  // Dolphin3's starting y
        let dolphin3Y = baseY
        let dolphin2Y = calculateYAtStep(12, baseY: baseY)  // Where dolphin3 would be at step 12
        let dolphin1Y = calculateYAtStep(24, baseY: baseY)  // Where dolphin3 would be at step 24

        // Create 3 dolphins with different positions and path offsets
        // Dolphins use water_gap1 (depth 7) to render just below the frontmost waterline (water_line0 at depth 8)
        // Dolphin 3 (trailing): x - (distance * 2), calculated y, offset=0
        let dolphin3 = DolphinEntity(
            name: "dolphin3_\(UUID().uuidString.prefix(8))",
            position: Position3D(spawnX - (distance * 2), Int(dolphin3Y), Depth.waterGap1),
            direction: randomDir,
            pathOffset: 0,
            path: path
        )
        dolphin3.defaultColor = .blue
        dolphin3.dieOffscreen = false

        // Create path visualization entity (full-width, positioned at min y)
        // Align with dolphin3 (offset 0) which starts at spawnX - (distance * 2)
        // Calculate minY first to position the entity correctly
        var pathMinY = baseY
        var currentPathY = baseY
        for step in path {
            if step.count >= 3 {
                let dy = step[2]
                currentPathY += dy
                pathMinY = min(pathMinY, currentPathY)
            }
        }
        let dolphin3StartX = spawnX - (distance * 2)
        let pathEntity = DolphinPathEntity(
            name: "dolphin_path_\(UUID().uuidString.prefix(8))",
            position: Position3D(0, 0, 1),  // Y will be calculated by entity based on minY
            path: path,
            baseY: baseY,  // Pass original baseY (8.0), not pathMinY
            dolphinStartX: dolphin3StartX
        )
        // Update position to the calculated min Y
        // pathEntity.position.y = pathEntity.calculateMinY()

        // Dolphin 2 (middle): x - distance, calculated y, offset=12
        let dolphin2 = DolphinEntity(
            name: "dolphin2_\(UUID().uuidString.prefix(8))",
            position: Position3D(spawnX - distance, Int(dolphin2Y), Depth.waterGap1),
            direction: randomDir,
            pathOffset: 12,
            path: path
        )
        dolphin2.defaultColor = .blueBright
        dolphin2.dieOffscreen = false

        // Dolphin 1 (lead): x, calculated y, offset=24
        let dolphin1 = DolphinEntity(
            name: "dolphin1_\(UUID().uuidString.prefix(8))",
            position: Position3D(spawnX, Int(dolphin1Y), Depth.waterGap1),
            direction: randomDir,
            pathOffset: 24,
            path: path
        )
        dolphin1.defaultColor = .cyan

        // Lead dolphin's death callback kills path entity, tells others to die offscreen, then spawns random object
        dolphin1.deathCallback = { [weak self] in
            pathEntity.kill()  // Kill the path visualization when dolphins die
            self?.spawnRandomObject()
        }

        // Set spawn callbacks
        dolphin1.spawnCallback = createSpawnCallback()
        dolphin2.spawnCallback = createSpawnCallback()
        dolphin3.spawnCallback = createSpawnCallback()

        // Add path visualization and all dolphins to entities
        entities.append(pathEntity)
        entities.append(dolphin1)
        entities.append(dolphin2)
        entities.append(dolphin3)
    }

}
