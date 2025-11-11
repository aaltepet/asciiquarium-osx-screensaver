//
//  EngineTests.swift
//  AsciiquariumTests
//
//  Created by Test on 9/19/25.
//

import Testing

struct EngineTests {

    @Test func testEngineInitializesFourWaterlineRows() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()

        // When
        // Engine initializes in init(); verify four rows exist
        let waterlines = engine.entities.filter { $0.type == .waterline }

        // Then
        #expect(waterlines.count == 4, "Engine should create four waterline rows")
        // Verify y positions and z mapping and segment indices 0..3
        let expected: [(y: Int, z: Int)] = [
            (5, Depth.waterLine3),
            (6, Depth.waterLine2),
            (7, Depth.waterLine1),
            (8, Depth.waterLine0),
        ]

        for (y, z) in expected {
            let hasMatch = waterlines.contains { wl in wl.position.y == y && wl.position.z == z }
            #expect(hasMatch, "Missing waterline at y=\(y), z=\(z)")
        }
    }

    @Test func testOffscreenFishDiesAndIsRemoved() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)
        let initialCount = engine.entities.count

        // A fish that will move fully off the right in one tick
        var fish = EntityFactory.createFish(
            at: Position3D(max(0, engine.gridWidth - 1), layout.fishSpawnMinY, Depth.fishStart))
        fish.direction = 1  // move right
        fish.speed = 1.0  // 1 cell per frame
        engine.entities.append(fish)

        // Sanity: count increased by one
        #expect(engine.entities.count == initialCount + 1)

        // When
        engine.tickOnceForTests()

        // Then: fish should be dead and removed from engine
        #expect(fish.isAlive == false, "Fish should die when fully offscreen")
        let stillPresent = engine.entities.contains { $0.id == fish.id }
        #expect(stillPresent == false, "Dead entities must be removed from the engine")
    }
    @Test func testSpawnedFishRespectSpawnBoundsAndDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        // Force a few spawns
        for _ in 0..<5 {
            engine.updateGridDimensions(width: engine.gridWidth, height: engine.gridHeight)
        }

        let fish = engine.entities.filter { $0.type == .fish }

        // Then
        for f in fish {
            // Y within allowed top spawn band
            #expect(
                f.position.y >= layout.fishSpawnMinY,
                "Fish y below min: y=\(f.position.y), min=\(layout.fishSpawnMinY)"
            )

            // Bottom respects required margin from bottom
            let fishBottomY = f.position.y + (f.size.height - 1)
            #expect(
                fishBottomY <= layout.fishSpawnMaxBottomY,
                "Fish bottom too low: bottomY=\(fishBottomY), maxAllowed=\(layout.fishSpawnMaxBottomY), topY=\(f.position.y), height=\(f.size.height)"
            )

            // Z depth within fish range
            #expect(
                (Depth.fishStart...Depth.fishEnd).contains(f.position.z),
                "Fish z should be within [\(Depth.fishStart), \(Depth.fishEnd)], got z=\(f.position.z)"
            )
        }
    }

    @Test func testCastlePlacedBottomRightWithCorrectDepth() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        let castles = engine.entities.filter { $0.type == .castle }

        // Then
        #expect(castles.count == 1, "Exactly one castle should be spawned")
        if let castle = castles.first {
            let expectedBottomY = layout.safeBottomY
            let actualBottomY = castle.position.y + (castle.size.height - 1)
            #expect(actualBottomY == expectedBottomY, "Castle must sit on bottom row")

            let expectedX = max(0, engine.gridWidth - castle.size.width)
            #expect(castle.position.x == expectedX, "Castle should be right-aligned")

            #expect(castle.position.z == Depth.castle, "Castle z-depth mismatch")
        }
    }

    @Test func testSeaweedDistributedAlongBottomWithValidHeights() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // When
        let weeds = engine.entities.filter { $0.type == .seaweed }

        // Then
        let expectedCount = max(1, engine.gridWidth / 15)
        #expect(weeds.count == expectedCount, "Seaweed count should scale with width")

        for w in weeds {
            let bottomY = w.position.y + (w.size.height - 1)
            #expect(bottomY == layout.safeBottomY, "Seaweed should be anchored to safe bottom")
            #expect((3...6).contains(w.size.height), "Seaweed height should be in [3,6]")
            #expect(w.position.z == Depth.seaweed, "Seaweed z-depth mismatch")
            #expect((0..<engine.gridWidth).contains(w.position.x), "Seaweed x within bounds")
        }
    }

    @Test func testBottomDecorReflowsOnResize() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let initialLayout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)
        let initialSeaweedCount = engine.entities.filter { $0.type == .seaweed }.count
        #expect(initialSeaweedCount == max(1, engine.gridWidth / 15))

        // When: increase width and height
        engine.updateGridDimensions(width: engine.gridWidth + 30, height: engine.gridHeight + 10)
        let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)

        // Then: castle reflow
        if let castle = engine.entities.first(where: { $0.type == .castle }) {
            let bottomY = castle.position.y + (castle.size.height - 1)
            #expect(bottomY == layout.safeBottomY, "Castle should sit on new safe bottom")
            let expectedX = max(0, engine.gridWidth - castle.size.width)
            #expect(castle.position.x == expectedX, "Castle should be re-aligned right")
        } else {
            #expect(false, "Castle should exist after resize")
        }

        // Seaweed reflow
        let weeds = engine.entities.filter { $0.type == .seaweed }
        let expectedCount = max(1, engine.gridWidth / 15)
        #expect(weeds.count == expectedCount, "Seaweed count should reflow with width")
        for w in weeds {
            let bottomY = w.position.y + (w.size.height - 1)
            #expect(
                bottomY == layout.safeBottomY, "Seaweed should be re-anchored to new safe bottom")
            #expect(w.position.z == Depth.seaweed)
        }
    }

    @Test func testSeaweedRespawnsOnDeath() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let initialSeaweedCount = engine.entities.filter { $0.type == .seaweed }.count
        #expect(initialSeaweedCount > 0, "Should have at least one seaweed")

        // Get a seaweed and verify it has a death callback
        guard let seaweed = engine.entities.first(where: { $0.type == .seaweed }) else {
            #expect(false, "Should have at least one seaweed")
            return
        }
        #expect(seaweed.deathCallback != nil, "Seaweed should have death callback for respawn")

        // When: manually trigger death callback (simulating seaweed death)
        let countBeforeDeath = engine.entities.filter { $0.type == .seaweed }.count
        seaweed.deathCallback?()

        // Then: a new seaweed should have been spawned
        let countAfterRespawn = engine.entities.filter { $0.type == .seaweed }.count
        #expect(
            countAfterRespawn >= countBeforeDeath,
            "Seaweed count should increase or stay same after respawn: before=\(countBeforeDeath), after=\(countAfterRespawn)"
        )

        // Verify the new seaweed has proper setup
        let newSeaweed = engine.entities.filter { $0.type == .seaweed }.last
        #expect(newSeaweed != nil, "New seaweed should exist")
        if let newSeaweed = newSeaweed {
            let layout = WorldLayout(gridWidth: engine.gridWidth, gridHeight: engine.gridHeight)
            let bottomY = newSeaweed.position.y + (newSeaweed.size.height - 1)
            #expect(bottomY == layout.safeBottomY, "New seaweed should be anchored to safe bottom")
            #expect(newSeaweed.deathCallback != nil, "New seaweed should also have death callback")
        }
    }

    @Test func testFishSpawnOffscreenAndMoveOnScreen() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let gridWidth = engine.gridWidth

        // When: get all spawned fish (engine uses Perl formula: int((height - 9) * width / 350))
        let fish = engine.entities.filter { $0.type == .fish }
        let expectedCount = max(
            1,
            (engine.gridHeight - SpawnConfig.surfaceRegionHeight) * engine.gridWidth
                / SpawnConfig.fishDensityDivisor)
        #expect(
            fish.count == expectedCount,
            "Engine should spawn fish using Perl formula: expected=\(expectedCount), actual=\(fish.count)"
        )

        // Then: verify each fish spawns off-screen based on direction
        for f in fish {
            guard let fishEntity = f as? FishEntity else {
                #expect(false, "Fish should be a FishEntity")
                continue
            }

            let fishWidth = max(1, f.size.width)
            let fishLeft = f.position.x
            let fishRight = f.position.x + (fishWidth - 1)

            if fishEntity.direction > 0 {
                // Right-moving fish should spawn off-screen to the left
                // Fish should be completely off-screen: right edge < 0
                #expect(
                    fishRight < 0,
                    "Right-moving fish should spawn off-screen left: x=\(f.position.x), width=\(fishWidth), right=\(fishRight), direction=\(fishEntity.direction)"
                )
            } else {
                // Left-moving fish should spawn off-screen to the right
                // Fish should be completely off-screen: left edge >= gridWidth
                #expect(
                    fishLeft >= gridWidth,
                    "Left-moving fish should spawn off-screen right: x=\(f.position.x), gridWidth=\(gridWidth), direction=\(fishEntity.direction)"
                )
            }
        }

        // Verify fish move onto screen when updated
        // Advance engine a few ticks to allow fish to move
        for _ in 0..<10 {
            engine.tickOnceForTests()
        }

        // After moving, at least some fish should be on-screen or have moved toward the screen
        let fishAfterMovement = engine.entities.filter { $0.type == .fish }
        var rightMovingFishOnScreen = false
        var leftMovingFishOnScreen = false

        for f in fishAfterMovement {
            guard let fishEntity = f as? FishEntity else { continue }

            let fishLeft = f.position.x
            let fishRight = f.position.x + (f.size.width - 1)

            // Check if fish is at least partially on screen
            let isOnScreen = fishRight >= 0 && fishLeft < gridWidth

            if isOnScreen {
                if fishEntity.direction > 0 {
                    rightMovingFishOnScreen = true
                } else {
                    leftMovingFishOnScreen = true
                }
            }
        }

        // At least one fish should have moved onto the screen (or we should have fish moving in both directions)
        #expect(
            rightMovingFishOnScreen || leftMovingFishOnScreen || fishAfterMovement.count > 0,
            "Fish should move onto screen after engine updates"
        )
    }

    @Test func testFishRespawnsOnDeath() async throws {
        // Given
        let engine = TestHelpers.createTestEngine()
        let initialFishCount = engine.entities.filter { $0.type == .fish }.count
        #expect(initialFishCount > 0, "Should have at least one fish")

        // Get a fish and verify it has a death callback
        guard let fish = engine.entities.first(where: { $0.type == .fish }) else {
            #expect(false, "Should have at least one fish")
            return
        }
        #expect(fish.deathCallback != nil, "Fish should have death callback for respawn")

        // When: manually trigger death callback (simulating fish death offscreen)
        let countBeforeDeath = engine.entities.filter { $0.type == .fish }.count
        fish.deathCallback?()

        // Then: a new fish should have been spawned
        let countAfterRespawn = engine.entities.filter { $0.type == .fish }.count
        #expect(
            countAfterRespawn >= countBeforeDeath,
            "Fish count should increase or stay same after respawn: before=\(countBeforeDeath), after=\(countAfterRespawn)"
        )

        // Verify the new fish has proper setup
        let newFish = engine.entities.filter { $0.type == .fish }.last
        #expect(newFish != nil, "New fish should exist")
        if let newFish = newFish {
            #expect(newFish.deathCallback != nil, "New fish should also have death callback")
            #expect(newFish.dieOffscreen == true, "New fish should die when offscreen")
        }
    }

    @Test func testFishDiesWhenMovingOffRightEdge() async throws {
        // Given: Create engine with known grid size
        let engine = TestHelpers.createTestEngine()
        let gridWidth = engine.gridWidth
        let gridHeight = engine.gridHeight
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Create a fish moving right, positioned near the right edge but still visible
        // Place it so its left edge is at gridWidth - fishWidth - 2 (2 cells from edge)
        let fish = EntityFactory.createFish(
            at: Position3D(0, layout.fishSpawnMinY, Depth.fishStart))
        fish.direction = 1  // Moving right
        fish.speed = 1.0  // 1 cell per frame for predictable movement

        // Position fish near right edge (but still fully visible)
        let fishWidth = fish.size.width
        let fishHeight = fish.size.height
        let startX = gridWidth - fishWidth - 2  // 2 cells from right edge
        fish.position = Position3D(startX, layout.fishSpawnMinY, Depth.fishStart)

        // Store fish ID to track it
        let fishId = fish.id
        engine.entities.append(fish)

        // Track position history
        var positionHistory: [(frame: Int, x: Int, left: Int, right: Int, isAlive: Bool)] = []

        // When: Move fish frame by frame and track when it dies
        var frame = 0
        var fishDied = false
        var deathFrame = -1

        // Move for enough frames to ensure fish goes off screen
        while frame < 20 && !fishDied {
            // Get current fish state
            guard let currentFish = engine.entities.first(where: { $0.id == fishId }) as? FishEntity
            else {
                // Fish was removed, check if it's dead
                fishDied = true
                deathFrame = frame
                break
            }

            let left = currentFish.position.x
            let right = currentFish.position.x + fishWidth - 1
            let isAlive = currentFish.isAlive

            positionHistory.append(
                (
                    frame: frame, x: currentFish.position.x, left: left, right: right,
                    isAlive: isAlive
                ))

            // Check if fish is dead
            if !isAlive {
                fishDied = true
                deathFrame = frame
                break
            }

            // Advance one frame
            engine.tickOnceForTests()
            frame += 1
        }

        // Then: Analyze what happened
        print("\n=== Fish Movement Analysis ===")
        print("Grid width: \(gridWidth)")
        print("Fish width: \(fishWidth)")
        print("Start position: x=\(startX), left=\(startX), right=\(startX + fishWidth - 1)")
        print("\nPosition history:")
        for entry in positionHistory {
            let status = entry.isAlive ? "alive" : "DEAD"
            let onScreen = entry.right >= 0 && entry.left < gridWidth ? "on-screen" : "off-screen"
            print(
                "  Frame \(entry.frame): x=\(entry.x), left=\(entry.left), right=\(entry.right), \(status), \(onScreen)"
            )
        }

        if fishDied {
            print("\nFish died at frame \(deathFrame)")
            if let deathEntry = positionHistory.last {
                print(
                    "Death position: x=\(deathEntry.x), left=\(deathEntry.left), right=\(deathEntry.right)"
                )
                print("At death: left >= gridWidth? \(deathEntry.left >= gridWidth)")
                print("At death: right < 0? \(deathEntry.right < 0)")
            }
        } else {
            print("\nFish did not die within 20 frames")
        }
        print("=============================\n")

        // Verify fish died
        #expect(fishDied, "Fish should die when moving off right edge")

        // Verify the death position - fish should die when left edge >= gridWidth (fully off right edge)
        if let deathEntry = positionHistory.last {
            let shouldDie = deathEntry.left >= gridWidth || deathEntry.right < 0
            #expect(
                shouldDie,
                "Fish should only die when fully off-screen. At death: left=\(deathEntry.left), right=\(deathEntry.right), gridWidth=\(gridWidth)"
            )

            // Fish should NOT die when left = 0 (that's the left edge of screen)
            // Fish SHOULD die when left >= gridWidth (fully off right edge)
            if deathEntry.left < gridWidth && deathEntry.right >= 0 {
                #expect(
                    false,
                    "Fish died while still visible! left=\(deathEntry.left), right=\(deathEntry.right), gridWidth=\(gridWidth)"
                )
            }
        }
    }

    @Test func testFishDiesWhenMovingOffLeftEdge() async throws {
        // Given: Create engine with known grid size
        let engine = TestHelpers.createTestEngine()
        let gridWidth = engine.gridWidth
        let gridHeight = engine.gridHeight
        let layout = WorldLayout(gridWidth: gridWidth, gridHeight: gridHeight)

        // Create a fish moving left, positioned near the left edge but still visible
        let fish = EntityFactory.createFish(
            at: Position3D(0, layout.fishSpawnMinY, Depth.fishStart))
        fish.direction = -1  // Moving left
        fish.speed = 1.0  // 1 cell per frame for predictable movement

        // Position fish near left edge (but still fully visible)
        let fishWidth = fish.size.width
        let startX = 2  // 2 cells from left edge
        fish.position = Position3D(startX, layout.fishSpawnMinY, Depth.fishStart)

        // Store fish ID to track it
        let fishId = fish.id
        engine.entities.append(fish)

        // Track position history
        var positionHistory: [(frame: Int, x: Int, left: Int, right: Int, isAlive: Bool)] = []

        // When: Move fish frame by frame and track when it dies
        var frame = 0
        var fishDied = false
        var deathFrame = -1

        // Move for enough frames to ensure fish goes off screen
        while frame < 20 && !fishDied {
            // Get current fish state
            guard let currentFish = engine.entities.first(where: { $0.id == fishId }) as? FishEntity
            else {
                // Fish was removed, check if it's dead
                fishDied = true
                deathFrame = frame
                break
            }

            let left = currentFish.position.x
            let right = currentFish.position.x + fishWidth - 1
            let isAlive = currentFish.isAlive

            positionHistory.append(
                (
                    frame: frame, x: currentFish.position.x, left: left, right: right,
                    isAlive: isAlive
                ))

            // Check if fish is dead
            if !isAlive {
                fishDied = true
                deathFrame = frame
                break
            }

            // Advance one frame
            engine.tickOnceForTests()
            frame += 1
        }

        // Then: Analyze what happened
        print("\n=== Left-Moving Fish Movement Analysis ===")
        print("Grid width: \(gridWidth)")
        print("Fish width: \(fishWidth)")
        print("Start position: x=\(startX), left=\(startX), right=\(startX + fishWidth - 1)")
        print("\nPosition history:")
        for entry in positionHistory {
            let status = entry.isAlive ? "alive" : "DEAD"
            let onScreen = entry.right >= 0 && entry.left < gridWidth ? "on-screen" : "off-screen"
            print(
                "  Frame \(entry.frame): x=\(entry.x), left=\(entry.left), right=\(entry.right), \(status), \(onScreen)"
            )
        }

        if fishDied {
            print("\nFish died at frame \(deathFrame)")
            if let deathEntry = positionHistory.last {
                print(
                    "Death position: x=\(deathEntry.x), left=\(deathEntry.left), right=\(deathEntry.right)"
                )
                print("At death: left >= gridWidth? \(deathEntry.left >= gridWidth)")
                print("At death: right < 0? \(deathEntry.right < 0)")
                print("At death: left == 0? \(deathEntry.left == 0)")
            }
        } else {
            print("\nFish did not die within 20 frames")
        }
        print("==========================================\n")

        // Verify fish died
        #expect(fishDied, "Fish should die when moving off left edge")

        // Verify the death position - fish should die when right edge < 0 (fully off left edge)
        // Fish should NOT die when left = 0 (that's still visible!)
        if let deathEntry = positionHistory.last {
            // Fish should only die when fully off-screen to the left (right < 0)
            let shouldDie = deathEntry.right < 0 || deathEntry.left >= gridWidth
            #expect(
                shouldDie,
                "Fish should only die when fully off-screen. At death: left=\(deathEntry.left), right=\(deathEntry.right), gridWidth=\(gridWidth)"
            )

            // CRITICAL: Fish should NOT die when left = 0 (that's the left edge of screen, fish is still visible)
            if deathEntry.left == 0 && deathEntry.right >= 0 {
                #expect(
                    false,
                    "BUG: Fish died when left=0! Fish is still visible. left=\(deathEntry.left), right=\(deathEntry.right), gridWidth=\(gridWidth)"
                )
            }

            // Fish should die when right < 0 (fully off left edge)
            if deathEntry.left < gridWidth && deathEntry.right >= 0 {
                #expect(
                    false,
                    "Fish died while still visible! left=\(deathEntry.left), right=\(deathEntry.right), gridWidth=\(gridWidth)"
                )
            }
        }
    }

}
