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
