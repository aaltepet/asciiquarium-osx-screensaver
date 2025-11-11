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

- [ ] Shark (underwater predator) depth and behavior stub
  - **Acceptance**:
    - Shark entities spawn with `z = shark`, move horizontally below the surface region, and die offscreen.
    - Teeth/collision helpers may be stubbed for later; shark remains underwater only.

- [ ] Fish entity colors based on body parts (Perl parity)
    - **Perl Reference** (see `docs/fish_color_parity_plan.md` for details):
      - Color masks use numbers 1-7: `1=body, 2=dorsal fin, 3=flippers, 4=eye, 5=mouth, 6=tailfin, 7=gills`
      - `rand_color()` function replaces each number with random color from `('c','C','r','R','y','Y','b','B','g','G','m','M')`
      - Eye (4) is replaced with 'W' (white) before randomization
      - Each body part gets independent random color
    - **Current Swift State**:
      - Fish use single-color masks with 'x' for opacity only
      - `defaultColor` is single random color for entire fish
      - Renderer already supports per-character colors from `colorMask` (ASCIIRenderer.swift lines 208-227)
    - **Implementation Plan**:
      1. Create numbered color masks (1-7) for all fish shapes matching Perl structure
      2. Implement `randomizeFishColors()` function (equivalent to Perl's `rand_color()`)
      3. Replace '4' with 'W' (eye = white) before randomization
      4. Replace numbers 1-9 with random colors during fish initialization
      5. Maintain opacity system: spaces = transparent, colors = opaque
    - **Acceptance**:
      - Fish color masks use numbers 1-7 for body parts (matching Perl)
      - Each body part gets random color from palette (c,C,r,R,y,Y,b,B,g,G,m,M)
      - Eye is always white ('W')
      - Each fish has unique, randomized multi-color appearance
      - Opacity system preserved (spaces remain transparent)
      - Visual parity with Perl: colorful, varied fish appearances

## Collision detection

- [ ] collision detection for shark
- [ ] collision detection for bubbles
- [X] do fish actually all move at the same speed? (completed - fish now have random speeds 0.25 to 2.25 matching Perl's `rand(2) + .25`) 
