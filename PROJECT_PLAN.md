# Asciiquarium macOS Project Plan

## Project Overview

**Project Name**: Asciiquarium macOS (Dual-Format Project)  
**Objective**: Port the asciiquarium terminal application to native macOS in two formats:

This dual-format project creates a comprehensive asciiquarium experience for macOS users. The shared core architecture ensures consistency between the screensaver and application formats while providing users with flexibility in how they want to enjoy the ASCII art aquarium.

The combination of terminal nostalgia, modern macOS integration, smooth animation, and dual format availability will create a unique offering that stands out from typical graphical screensavers while maintaining the simplicity and charm that makes asciiquarium special.

1. **macOS Screensaver** - Traditional screensaver integration
2. **macOS Application** - Standalone windowed application

**Target Platform**: macOS 10.15+ (Catalina and later)  
**Development Language**: Swift  
**Frameworks**: ScreenSaver framework + AppKit framework  
**License**: GNU General Public License v2 (GPL-2.0) - matching original asciiquarium

## Problem Statement

While asciiquarium exists as a terminal application for macOS (installable via Homebrew), there is no native macOS integration. 
Users who want to enjoy the ASCII art aquarium must either:

1. Keep a terminal window open with asciiquarium running
2. Use third-party solutions that may not integrate well with macOS
3. Miss out on the screensaver experience entirely

## Solution

Create a dual-format native macOS implementation:

### 1. macOS Screensaver (.saver bundle)

- Integrates seamlessly with macOS screensaver system
- Runs automatically when system is idle
- Traditional screensaver experience

### 2. macOS Application (.app bundle)

- Standalone windowed application
- Perfect for demonstrations and testing

### Shared Core Architecture

Both formats share the same core asciiquarium engine:

- Native Swift implementation (no Perl dependencies)
- Identical animation and rendering logic
- Shared configuration system

## Technical Architecture

### Shared Core Components

1. **Engine** (Core animation engine)

   - Manages entity lifecycle: spawning, updating, and removal
   - Handles fish, seaweed, waterline, castle, bubble, shark, splat, and other entity types
   - Handles animation timing and physics (deltaTime-based updates)
   - **Mask-based pixel-level collision detection** (two-phase: bounding box rejection + pixel overlap)
   - Entity death management (offscreen, time-based, frame-based)

2. **ASCIIRenderer** (Text rendering system)

   - Renders ASCII art with proper monospace font
   - Handles text positioning and scaling using grid-based coordinates
   - Manages color schemes and styling (color masks, default colors, per-character coloring)
   - Supports transparency and color masking for compositing
   - Depth-based rendering order (z-sorting)

3. **Entities** (objects rendered on screen)

   - Fish, shark, castle, seaweed, bubble, waterline,
     ship, whale, monster, bigFish, ducks, dolphins, swan, splat, teeth, fishhook, fishline, hookPoint
   - Movement system with configurable speed and direction
   - Collision detection with physical entities
   - Lifecycle management (spawn, update, death)

4. **WorldLayout** (Environmental structure)
  
   - Fixed region boundaries (sky, surface, water, bottom rows)
   - Depth layers (z-index) with predefined constants for proper layering
   - Spawn helpers for entity placement (fish spawning bounds, safe bottom anchoring)

### Format-Specific Components

#### Screensaver Format (.saver)

5. **AsciiquariumScreensaverView** (ScreenSaverView subclass)
   - Integrates with macOS screensaver system
   - Handles screensaver-specific lifecycle
   - Manages preview and full-screen modes

#### Application Format (.app)

6. **AsciiquariumApp** (NSApplication delegate)

   - Creates and manages main window
   - Handles application lifecycle
   - Provides window controls and resizing

7. **ContentView** (NSView subclass)
   - Displays animation in resizable window
   - Handles window-specific interactions
   - Manages window focus and updates

### Format-Specific Options

#### Screensaver (.saver)

- **Preview Mode**: Show animation in System Preferences
- **Full Screen**: Full screen display when idle
- **Start Delay**: Delay before screensaver activates

#### Application (.app)

- **Window Size**: Remember last window size
- **Always on Top**: Keep window above other applications
- **Start Minimized**: Start in dock when launched
- **Mini in menubar**: render mini acquarium in osx menu

## Screen Regions and Spawning Parity Checklist

- [X] Surface entity spawners (ship, whale, monster, ducks, dolphins, swan)
  - **Acceptance**:
    - Spawners create entities constrained to surface rows (near `y ∈ 0…8`) and use appropriate gap depths:
      - Ship at `water_gap1`, Whale at `water_gap2`, Monster at `water_gap2`, Ducks/Dolphins/Swan at `water_gap3`.
    - Entities traverse horizontally, die offscreen, and respawn randomly similar to Perl.
    - Sea monster only ever appears in the surface region.
    - Depth gaps `water_gap3/2/1/0` are reserved and used so surface entities render between the 4 waterline rows.
    - Renderer sorts by `position.z` so surface entities appear visually between adjacent waterline rows.
    - Unit tests: a (stub or real) surface entity at a gap depth renders between adjacent waterline rows in the final buffer (z-order verified).

- [X] Bubble pops when reaching water surface
  - **Acceptance**:
    - ✅ Bubbles rise and are killed when colliding with any `waterline` row.
    - ✅ Verified via unit tests that bubbles never render above the surface.
    - ✅ Unit tests: bubble rises frame-by-frame; last alive position is immediately below the topmost waterline row; bubble is killed upon intersection; no frames show bubble above surface.
    - **Implementation**: Collision detection system implemented with bubble collision handler that kills bubbles on waterline collision. 6 comprehensive tests in CollisionTests.swift verify behavior.

- [X] Shark (underwater predator) depth and behavior
  - **Acceptance**:
    - ✅ Shark entities spawn with `z = shark`, move horizontally below the surface region, and die offscreen.
    - ✅ Shark collision handler implemented: shark kills fish on collision and spawns splat entity.
    - ✅ Shark has color masks for proper rendering (left and right facing).
    - ✅ SplatEntity moved to its own file (no longer placeholder).
    - **Implementation**: SharkEntity with collision detection, SplatEntity with animation frames, comprehensive unit tests.

## Collision Detection System

### Overview
The collision detection system needs to handle different types of collisions with different outcomes:
- **Death collisions**: Entity is killed upon collision (e.g., bubble + waterline)
- **Spawn collisions**: New entities are created upon collision (e.g., shark + fish → blood splat)
- **Behavior collisions**: Entity behavior changes (e.g., fishhook + fish → retraction)

### Current State
- ✅ `BaseEntity.checkCollisions()` exists with **mask-based pixel-level collision detection**
- ✅ Two-phase collision detection: bounding box rejection + mask-based pixel overlap
- ✅ `isPhysical` flag exists to mark entities that participate in collisions
- ✅ `collisionHandler` property exists on entities
- ✅ Engine executes collision detection during updates (after position updates)
- ✅ Collision handler signature updated to `((Entity, [Entity]) -> Void)?` (entity + collision partners)
- ✅ Bubble collision handler set up (bubble + waterline → death)
- ✅ Full-width entity bounds handling (EntityFullWidth overrides getBounds() for proper collision detection)
- ✅ **Mask-based collision detection**: Uses `colorMask` or `shape` + `transparentChar` to determine visible pixels
- ✅ **Shark collision handler**: Shark kills fish on collision and spawns splat entity
- ✅ Special handling for full-width entities (waterlines) - Y-coordinate overlap check

### Design Questions
1. **Collision Handler Signature**: Should handlers receive:
   - Just the colliding entity? `((Entity) -> Void)?`
   - The colliding entity + all entities? `((Entity, [Entity]) -> Void)?`
   - The colliding entity + collision list? `((Entity, [Entity]) -> Void)?`
   
2. **Collision Types**: Should we have typed collision events?
   - `CollisionType.death` - kills the entity
   - `CollisionType.spawn(entitySpec)` - spawns new entity
   - `CollisionType.custom(handler)` - custom behavior
   
3. **Engine Integration**: Where should collision detection run?
   - After position updates in `Engine.updateEntities()`?
   - Before or after entity removal?
   - How to handle collisions with entities that are about to die?

### Implementation Tasks
- [X] Design collision handler signature and collision type system (using `((Entity, [Entity]) -> Void)?`)
- [X] Implement collision detection loop in `Engine.updateEntities()` (runs after position updates, before entity removal)
- [X] Set up bubble collision handler (bubble + waterline → death)
- [X] Fix full-width entity bounds for collision detection (EntityFullWidth overrides getBounds())
- [X] Add comprehensive tests for bubble collision (6 tests in CollisionTests.swift)
- [X] **Implement mask-based pixel-level collision detection** (replaces bounding box-only detection)
- [X] **Set up shark collision handler** (shark + fish → spawn splat)
- [X] **Handle edge cases** (collisions with dying entities, offscreen entities) - dead entities collected and removed correctly
- [X] Fish speed randomization (completed - fish now have random speeds 0.25 to 2.25 matching Perl's `rand(2) + .25`)
- [X] **Add `IntPoint` type** for pixel coordinate tracking
- [X] **Add `getVisiblePixels()` method** to convert mask/shape to world coordinates

## Entity Spawning System

### Overview
Entities need the ability to spawn other entities during their lifecycle. Examples:
- **Fish spawn bubbles**: Fish have a 0.5% chance per frame to generate a bubble (adjusted from 3% due to frame rate differences)
- **Shark spawns splat**: When shark collides with fish, spawn a blood splat at collision point
- **Future**: Other entities may spawn things (e.g., fishhook spawning behavior)

### Current State
- ✅ `BubbleEntity` exists and is configured
- ✅ `EntityFactory.createBubble()` exists
- ✅ `FishEntity` has `shouldGenerateBubble()` and `generateBubblePosition()` methods
- ✅ Entities can add new entities to the engine's entity list (via spawn callback)
- ✅ Mechanism exists for entities to request spawning during updates (spawn callback system)

### Proposed Design: Engine Spawn Callback

**Option 1: Spawn Callback Closure**
```swift
// In Engine
typealias SpawnCallback = (Entity) -> Void
var spawnCallback: SpawnCallback?

// Entities receive spawn callback during initialization or update
// Fish can call: spawnCallback?(newBubble)
```

**Option 2: Weak Engine Reference**
```swift
// Entities hold weak reference to engine
protocol EntitySpawner {
    func spawn(_ entity: Entity)
}

// Engine conforms to EntitySpawner
// Entities call: engine?.spawn(newBubble)
```

**Option 3: Spawn Request Queue**
```swift
// Entities add spawn requests to a queue
// Engine processes queue after all entity updates
struct SpawnRequest {
    let entity: Entity
    let position: Position3D?
}

// Engine processes spawn requests at end of update cycle
```

### Recommended Design: Spawn Callback (Option 1)

**Rationale:**
- Simple and explicit
- No retain cycles (callback can be weak)
- Entities don't need direct engine reference
- Easy to test (can inject mock spawn callback)

**Implementation:**
1. Engine provides spawn callback to entities during initialization or update
2. Entities call callback when they want to spawn something
3. Engine adds spawned entities to its entity list
4. Spawned entities are processed in the next update cycle

**Example Usage:**
```swift
// In FishEntity.update()
if shouldGenerateBubble() {
    let bubblePos = generateBubblePosition()
    let bubble = EntityFactory.createBubble(at: bubblePos)
    spawnCallback?(bubble)  // Engine will add to entities list
}
```

### Implementation Tasks
- [X] Add `spawnCallback` property to `Entity` protocol (optional)
- [X] Engine sets spawn callback on entities during initialization/update
- [X] Implement fish bubble generation in `FishEntity.update()`
- [X] Handle spawn timing (immediate - entities added during update cycle)
- [X] Add unit tests for entity spawning (6 comprehensive tests in SpawnCallbackTests.swift)
- [X] **Implement shark splat spawning** in shark collision handler (spawns SplatEntity at collision point)
- [X] **SplatEntity moved to its own file** (no longer in PlaceholderEntities.swift)

## Next Steps & Recommendations

### Completed Systems ✅
1. **Core Entity System**: Entity protocol, BaseEntity, EntityFactory
2. **Collision Detection**: Mask-based pixel-level collision detection (two-phase: bounding box + pixel overlap)
3. **Entity Spawning**: Spawn callback system for entities to create other entities
4. **Environment Entities**: Waterline, Castle, Seaweed
5. **Marine Life**: Fish (with bubble spawning), Shark (with collision handler), Bubble, Splat

### Recommended Next Steps

#### Priority 1: Surface Entities (High Impact, Medium Complexity)
**Why**: Surface entities add visual variety and complete the "aquarium" experience. They're visible and engaging.

**Tasks**:
- [X] Implement **Ship** entity
  - Spawns at surface region (y ∈ 0…8) at `water_gap1` depth
  - Moves horizontally, dies offscreen, respawns
  - ASCII art ship shape
- [X] Implement **Ducks** entity
  - Spawns at surface region at `water_gap3` depth
  - Moves horizontally, dies offscreen, respawns
  - Animated duck shapes
- [X] Implement **Swan** entity
  - Similar to ducks but with swan-specific shape
  - Spawns at `water_gap3` depth
- [X] Implement **Dolphins** entity
  - Surface entity at `water_gap3` depth
  - May have jumping animation
- [X] Implement **Whale** entity
  - Large surface entity at `water_gap2` depth
  - Spawns occasionally
- [X] Implement **Monster** entity
  - Sea monster at surface region, `water_gap2` depth
  - Only appears in surface region (never underwater)

**Acceptance Criteria**:
- All surface entities spawn in correct region (y ∈ 0…8)
- Entities use correct depth gaps (water_gap1/2/3)
- Entities render between waterline rows (z-order verified)
- Entities move horizontally and respawn offscreen
- Unit tests verify spawn positions and depth layers

#### Priority 2: Teeth Entity (Low Complexity, Completes Shark) ✅
**Why**: The shark in Perl has a "teeth" helper entity that moves with it. This completes the shark implementation.

**Tasks**:
- [X] Implement **TeethEntity**
  - Spawns with shark at slightly different z-depth
  - Moves in sync with shark
  - Simple shape (asterisk `*`)
  - Collision detection (or just visual)

**Acceptance Criteria**:
- ✅ Teeth spawn with shark
- ✅ Teeth move in sync with shark
- ✅ Teeth positioned correctly relative to shark

#### Priority 3: Fishing Equipment (Medium Complexity, Interactive Feature)

**Detailed Implementation Plan**:

- [X] **Phase 1: Porting Visuals**
    - [X] Create `FishhookEntity.swift` with the hook ASCII art and state tracking.
    - [X] Create `FishlineEntity.swift` using a vertical string of `|` characters.
    - [X] Create `HookPointEntity.swift` for the physical tip of the hook.
    - [X] Remove existing placeholders from `PlaceholderEntities.swift`.

- [X] **Phase 2: Movement & Synchronization**
    - [X] Implement synchronized `moveEntity` logic (shared speed and direction).
    - [X] Add "Max Depth" logic (stop descent at ~75% screen height).
    - [X] Create a mechanism to link states (if one entity retracts, all retract).

- [ ] **Phase 3: Spawning Integration**
    - [ ] Add `spawnFishhook()` to `AsciiquariumEngine.swift`.
    - [ ] Update the Engine's main loop to trigger hook spawning based on a random chance.

- [ ] **Phase 4: Lifecycle & Retraction**
    - [ ] Implement timed retraction (auto-reel-in if nothing is caught after X seconds).
    - [ ] Ensure all three entities are cleaned up together via `deathCallback`.

- [ ] **Phase 5: The "Catch" (Collisions)**
    - [ ] Implement `collisionHandler` in `HookPointEntity`.
    - [ ] Add a `isHooked` state to `FishEntity`.
    - [ ] Update `FishEntity.moveEntity` to follow the `HookPointEntity` while hooked.

**Acceptance Criteria**:
- Hook drops and retracts on fish collision
- Line connects hook to surface
- Proper collision detection with fish
- Caught fish are pulled to the surface
