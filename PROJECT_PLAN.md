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
   - Handles fish, seaweed, waterline, castle, bubble, shark, and other entity types
   - Handles animation timing and physics (deltaTime-based updates)
   - Collision detection system with bounding box overlaps
   - Entity death management (offscreen, time-based, frame-based)

2. **ASCIIRenderer** (Text rendering system)

   - Renders ASCII art with proper monospace font
   - Handles text positioning and scaling using grid-based coordinates
   - Manages color schemes and styling (color masks, default colors, per-character coloring)
   - Supports transparency and alpha masking for compositing
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

- [x] Define shared depth map and region boundaries
  - **Acceptance**:
    - `Depth` constants exist for: `water_line3=2`, `water_gap3=3`, `water_line2=4`, `water_gap2=5`, `water_line1=6`, `water_gap1=7`, `water_line0=8`, `water_gap0=9`, `castle=1`, `seaweed=2`, `shark=2`, `fishStart=3`, `fishEnd=20`.
    - Underwater rendering order (back→front): `castle < seaweed (= shark) < fish`.
    - `Region` helper exposes fixed Y ranges: `sky` rows `0–4`, `surface` rows `5–8` (4 rows), `water` rows `9…gridHeight-1`, and `bottomRows` covering the last row used by bottom entities.

- [x] Implement multi-layered water surface (4 rows)
  - **Acceptance**:
    - Four `waterline` entities are created at rows `y = 5, 6, 7, 8`.
    - Each row uses one of the four canonical segments; rows tile across full width.
    - Rows use z-depths: `water_line3`, `water_line2`, `water_line1`, `water_line0` respectively.
    - Color is cyan; waterlines are physical (for bubble collision).
    - Unit tests:
      - WaterlineEntity: returns exactly one line; `getShape(for: W)` length == W; uses its fixed canonical segment repeated to width (no randomization).
      - WaterlineEntity: `moveEntity` returns nil; shape content unchanged across multiple updates.
      - WaterlineEntity: `isPhysical == true`, `defaultColor == .cyan`.
      - Engine: initializes scene with exactly 4 waterline entities at y = 5, 6, 7, 8 and correct z mapping (`waterLine3/2/1/0`).


- [x] Fish spawning respects water region and depth range
  - **Acceptance**:
    - Fish spawn with `y ≥ 9` and within screen height minus fish height.
    - Fish z-depth is randomized in `[fishStart, fishEnd]`.
    - No fish appear above the water surface rows.
    - Unit tests: newly spawned fish satisfy `y ≥ 9` and `z ∈ [fishStart, fishEnd]`; no fish with `y < 9`.
    - fish spawn offscreen and move on screen

- [x] Bottom placement: castle and seaweed
  - **Acceptance**:
    - One castle is placed at bottom-right with `z = castle` and correct ASCII art.
    - Seaweed instances spawn at random x along the bottom, height 3–6, with `z = seaweed`.
    - Seaweed count scales with width (≈ `gridWidth / 15`).
    - Reflows correctly on grid resize (castle stays bottom-right; seaweed count/positions update).

- [ ] Surface entity spawners (ship, whale, monster, ducks, dolphins, swan)
  - **Acceptance**:
    - Spawners create entities constrained to surface rows (near `y ∈ 0…8`) and use appropriate gap depths:
      - Ship at `water_gap1`, Whale at `water_gap2`, Monster at `water_gap2`, Ducks/Dolphins/Swan at `water_gap3`.
    - Entities traverse horizontally, die offscreen, and respawn randomly similar to Perl.
    - Sea monster only ever appears in the surface region.
    - Depth gaps `water_gap3/2/1/0` are reserved and used so surface entities render between the 4 waterline rows.
    - Renderer sorts by `position.z` so surface entities appear visually between adjacent waterline rows.
    - Unit tests: a (stub or real) surface entity at a gap depth renders between adjacent waterline rows in the final buffer (z-order verified).

- [ ] Bubble pops when reaching water surface
  - **Acceptance**:
    - Bubbles rise and are killed when colliding with any `waterline` row.
    - Verified via unit or visual test that bubbles never render above the surface.
    - Unit tests: bubble rises frame-by-frame; last alive position is immediately below the topmost waterline row; bubble is killed upon intersection; no frames show bubble above surface.

- [ ] Underwater compositing masks (selective transparency)
  - **Implementation**: Uses `colorMask` to control both color and opacity for non-full-width entities.
    - **ColorMask Opacity Control**: The `colorMask` property controls opacity per-pixel:
      - Space character in `colorMask` = transparent pixel (background shows through)
      - Non-space character in `colorMask` = opaque pixel (blocks background, shows entity)
    - **Rendering Logic** (`ASCIIRenderer.swift`):
      - When `colorMask` is provided, it determines opacity before checking `transparentChar`
      - Opaque pixels (non-space in mask) draw the shape character, blocking background
      - Transparent pixels (space in mask) skip drawing, allowing background to show
      - Falls back to `transparentChar` logic if no `colorMask` is provided
    - **Interior Spaces**: Spaces within entity shapes (e.g., inside fish silhouettes) are marked as opaque in the `colorMask`, preventing background entities from showing through
    - **Exterior Spaces**: Leading/trailing spaces outside the entity shape are marked as transparent in the `colorMask`, allowing background to show through
    - **Castle Windows**: Castle can use `colorMask` with spaces to mark window cutouts as transparent while keeping solid parts opaque
  - **Acceptance**:
    - ✅ Non-full-width entities composite using `colorMask` so only space outside the entity's silhouette is transparent
    - ✅ Spaces inside fish silhouettes remain opaque (do not reveal castle/seaweed behind) when marked in `colorMask`
    - ✅ Castle window cutouts follow `colorMask` (spaces = transparent, non-space = opaque)
    - ✅ Unit tests: `testColorMaskControlsOpacityInteriorSpacesOpaque` proves interior spaces block background; exterior spaces remain pass-through

- [ ] Shark (underwater predator) depth and behavior stub
  - **Acceptance**:
    - Shark entities spawn with `z = shark`, move horizontally below the surface region, and die offscreen.
    - Teeth/collision helpers may be stubbed for later; shark remains underwater only.

- [ ] Centralize configuration for spawn cadence and densities
  - **Acceptance**:
    - Constants exist for spawn intervals, fish density (analog of `screen_size/350`), and seaweed count per width.
    - Tuning values are grouped in a single config area used by the engine.

- [ ] Documentation and tests for regions and spawners
  - **Acceptance**:
    - PROJECT_PLAN updated with region diagram and depth table reference.
    - Unit tests (where feasible) or developer runbook describe manual verification steps for each region/spawner.

- [ ] Fish placement refinement
    - Fish don't appear in the middle of the canvas.  They always spawn off-screen, moving onto the screen, 
      and dying after moving off the opposite end of the screen.
    - Fish don't spawn below the bottom of the screen.  Take the height of the fish into account.

- [ ] Colors
    - review the color capability of the the original perl source code
    - Add a generalized color-map capability to the asciirenderer and entities
    - list the entities and add them to this todo list
    - proceed one entity at a time, I want to review each

### Animation Parity Tasks

- [ ] Seaweed animation parity with Perl
  - **Acceptance**:
    - Sway timing includes randomness comparable to Perl (interval jitter/phase differences).
    - Visual check across multiple minutes shows non-uniform, organic swaying.
    - Add unit/visual tests to validate timing variance bounds (not exact determinism).
- [ ] Seaweed placement should be random

## Known Issues / TODOs

- [ ] fish should only spawn off-screen
- [ ] Underwater compositing: interior spaces in fish should be opaque; implement alpha masks
- [ ] seaweed placement should be random
- [ ] seaweed animation should be random
- [ ] collision detection for shark
- [ ] collision detection for bubbles
