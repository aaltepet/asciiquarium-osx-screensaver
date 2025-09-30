# Asciiquarium macOS Project Plan

## Project Overview

**Project Name**: Asciiquarium macOS (Dual-Format Project)  
**Objective**: Port the asciiquarium terminal application to native macOS in two formats:

1. **macOS Screensaver** - Traditional screensaver integration
2. **macOS Application** - Standalone windowed application

**Target Platform**: macOS 10.15+ (Catalina and later)  
**Development Language**: Swift  
**Frameworks**: ScreenSaver framework + AppKit framework  
**License**: GNU General Public License v2 (GPL-2.0) - matching original asciiquarium

## Problem Statement

While asciiquarium exists as a terminal application for macOS (installable via Homebrew), there is no native macOS integration. Users who want to enjoy the ASCII art aquarium must either:

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
- Can be run on-demand
- Resizable window with full control
- Perfect for demonstrations and testing

### Shared Core Architecture

Both formats share the same core asciiquarium engine:

- Native Swift implementation (no Perl dependencies)
- Identical animation and rendering logic
- Shared configuration system
- Consistent user experience across both formats

## Technical Architecture

### Shared Core Components

1. **AsciiquariumEngine** (Core animation engine)

   - Native Swift implementation of asciiquarium logic
   - Manages fish, seaweed, and water line entities
   - Handles animation timing and physics
   - No external dependencies (Perl-free)

2. **ASCIIRenderer** (Text rendering system)

   - Renders ASCII art with proper monospace font
   - Handles text positioning and scaling
   - Manages color schemes and styling
   - Shared between both formats

3. **ConfigurationManager** (User preferences)
   - Manages settings for both formats
   - Handles configuration UI
   - Persists user preferences
   - Unified configuration system

### Format-Specific Components

#### Screensaver Format (.saver)

4. **AsciiquariumScreensaverView** (ScreenSaverView subclass)
   - Integrates with macOS screensaver system
   - Handles screensaver-specific lifecycle
   - Manages preview and full-screen modes

#### Application Format (.app)

5. **AsciiquariumApp** (NSApplication delegate)

   - Creates and manages main window
   - Handles application lifecycle
   - Provides window controls and resizing

6. **AsciiquariumView** (NSView subclass)
   - Displays animation in resizable window
   - Handles window-specific interactions
   - Manages window focus and updates

### Dependencies

- **System Requirements**:

  - macOS 10.15+ (Catalina)
  - Xcode 12.0+
  - Swift 5.0+

- **External Dependencies**: None (fully native implementation)
  - No Perl dependencies
  - No external scripts required
  - Self-contained Swift implementation

## Development Phases

### Phase 1: Project Setup and Core Engine (Week 1)

- [x] Set up Xcode project with ScreenSaver template
- [x] Research asciiquarium implementation details
- [x] Create native Swift asciiquarium engine
- [x] Implement core animation logic
- [x] Create basic project structure

**Deliverables**:

- Working Xcode project with dual targets
- Native Swift asciiquarium engine
- Basic animation system working

### Phase 2: Dual Format Implementation (Week 2)

- [x] Implement standalone application format
- [x] Create AsciiquariumView for windowed display
- [x] Implement screensaver format
- [x] Create shared core components
- [x] Test both formats

**Deliverables**:

- Functional standalone application
- Working screensaver format
- Shared core architecture

### Phase 3: Polish and Features (Week 3)

- [ ] Add configuration interface for both formats
- [ ] Implement different color schemes
- [ ] Add animation speed controls
- [ ] Optimize performance
- [ ] Add proper font scaling

**Deliverables**:

- Complete configuration system
- Multiple visual options
- Performance optimized

### Phase 4: Testing and Distribution (Week 4)

- [ ] Comprehensive testing on different macOS versions
- [ ] Test both formats on various screen sizes
- [ ] Create installation packages for both formats
- [ ] Write documentation
- [ ] Prepare for distribution

**Deliverables**:

- Fully tested .saver and .app bundles
- Installation documentation
- User guide for both formats

## Technical Specifications

### Screensaver Requirements (.saver)

- **Bundle Format**: `.saver` bundle
- **Installation Path**: `~/Library/Screen Savers/`
- **System Integration**: Full macOS screensaver compatibility
- **Performance**: < 5% CPU usage on idle
- **Memory**: < 50MB RAM usage

### Application Requirements (.app)

- **Bundle Format**: `.app` bundle
- **Installation Path**: `/Applications/` or user-specified
- **Window Management**: Resizable, closable, minimizable
- **Performance**: < 10% CPU usage during active use
- **Memory**: < 100MB RAM usage

### ASCII Art Rendering

- **Font**: Monospace font (Menlo, Monaco, or Courier)
- **Scaling**: Automatic scaling to fit screen
- **Colors**: Support for both monochrome and colored output
- **Frame Rate**: 10-15 FPS for smooth animation

### Configuration Options (Shared)

- **Animation Speed**: Slow, Normal, Fast
- **Color Scheme**: Monochrome, Colored, Custom
- **Font Size**: Auto, Small, Medium, Large
- **Background**: Black, Dark Gray, Custom

### Format-Specific Options

#### Screensaver (.saver)

- **Preview Mode**: Show animation in System Preferences
- **Full Screen**: Full screen display when idle
- **Start Delay**: Delay before screensaver activates

#### Application (.app)

- **Window Size**: Remember last window size
- **Always on Top**: Keep window above other applications
- **Start Minimized**: Start in dock when launched

## Risk Assessment

### High Risk

- **Performance**: Maintaining smooth animation without high CPU usage in both formats
- **Memory Management**: Ensuring efficient memory usage across both formats
- **Animation Synchronization**: Keeping both formats in sync with shared core

### Medium Risk

- **Font Rendering**: Ensuring ASCII art displays correctly across different systems
- **Screen Sizing**: Adapting to various screen resolutions and aspect ratios
- **macOS Compatibility**: Ensuring compatibility across different macOS versions
- **Window Management**: Handling window resizing and focus in application format

### Low Risk

- **User Interface**: Configuration interface implementation for both formats
- **Distribution**: Packaging and installation process for both formats
- **Code Sharing**: Managing shared core components between formats

## Mitigation Strategies

1. **Performance**: Implement efficient frame caching and optimized rendering for both formats
2. **Memory Management**: Use shared core components to minimize memory duplication
3. **Compatibility**: Test on multiple macOS versions and screen configurations
4. **Font Issues**: Use system monospace fonts and implement proper scaling
5. **Code Sharing**: Create well-defined interfaces between shared core and format-specific code

## Success Criteria

### Minimum Viable Product (MVP)

- [x] Standalone application displays asciiquarium animation
- [x] Screensaver displays asciiquarium animation
- [x] Basic configuration options available
- [x] Stable operation for extended periods
- [x] Proper installation and uninstallation for both formats

### Full Feature Set

- [ ] Smooth animation with configurable speed
- [ ] Multiple color schemes and visual options
- [ ] Comprehensive configuration interface for both formats
- [ ] Excellent performance and stability
- [ ] Professional packaging and documentation
- [ ] Shared core architecture working seamlessly

## Timeline

**Total Duration**: 4 weeks (reduced due to dual format efficiency)  
**Development Time**: ~30-40 hours  
**Testing Time**: ~10-15 hours

### Week-by-Week Breakdown

- **Week 1**: Project setup, core engine, basic structure ✅
- **Week 2**: Dual format implementation, shared architecture ✅
- **Week 3**: Configuration, polish, optimization
- **Week 4**: Testing, packaging, documentation

## Resources and Tools

### Development Tools

- Xcode 12.0+
- macOS development environment
- Terminal for testing asciiquarium
- Git for version control

### Reference Materials

- Apple ScreenSaver framework documentation
- asciiquarium source code and documentation
- Existing screensaver implementations
- macOS Human Interface Guidelines

## Future Enhancements

### Version 2.0 Features

- Multiple aquarium themes
- Sound effects integration
- Interactive elements (click to feed fish)
- Custom ASCII art support
- Network aquarium (multiple screens)
- Shared configuration between formats

### Long-term Vision

- Open source community contributions
- Cross-platform versions (Windows, Linux)
- Advanced customization options
- Integration with other terminal applications
- Plugin system for custom entities

## Conclusion

This dual-format project creates a comprehensive asciiquarium experience for macOS users. The shared core architecture ensures consistency between the screensaver and application formats while providing users with flexibility in how they want to enjoy the ASCII art aquarium.

The combination of terminal nostalgia, modern macOS integration, smooth animation, and dual format availability will create a unique offering that stands out from typical graphical screensavers while maintaining the simplicity and charm that makes asciiquarium special.

**Key Advantages of Dual Format Approach:**

- **Flexibility**: Users can choose screensaver or application based on their needs
- **Testing**: Application format makes debugging and development easier
- **Code Reuse**: Shared core reduces maintenance overhead
- **User Experience**: Both formats provide the same high-quality experience

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
  - **Acceptance**:
    - Non-full-width entities composite with an alpha mask per-entity so only space outside the entity’s silhouette is transparent.
    - Spaces inside fish silhouettes remain opaque (do not reveal castle/seaweed behind).
    - Castle window cutouts follow its mask (intended holes only), otherwise castle remains opaque.
    - Unit tests: render order fish/seaweed/castle proves no background leaks through interior spaces; outside bounding spaces remain pass-through.

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

## Known Issues / TODOs

- [X] Bottom anchoring bug: castle/seaweed must never render below screen bottom
- [X] Depth layering bug: fish render behind seaweed/castle per `Depth`
- [X] Entity death should remove the entity from the engine
- [ ] Underwater compositing: interior spaces in fish should be opaque; implement alpha masks
- [ ] seaweed placement should be random
- [ ] seaweed animation should be random
- [ ] collision detection for shark
- [ ] collision detection for bubbles
- [ ] pirate ship
- [ ] is 'tickOnceForTests' really necessary?  Doesn't engine have the ability to progress just once?
