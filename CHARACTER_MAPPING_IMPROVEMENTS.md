# Character Mapping Improvements - Implementation Plan

## Overview
This document tracks the step-by-step implementation of improved font scaling and character mapping for the Asciiquarium screensaver to fix issues with character positioning and scene bounds.

## Implementation Steps

### Step 1: Implement Dynamic Font Sizing and Precise Character Metrics
- [x] Replace the fixed 14pt font with dynamic sizing based on available space
- [x] Use `NSLayoutManager` to get accurate character dimensions
- [x] Calculate optimal font size to fit the display bounds
- [x] Add proper character width/height calculations that account for actual rendering
- [x] **Tests**: Verify font size calculation accuracy for different bounds
- [x] **Tests**: Validate character width/height calculations match actual rendering
- [x] **Tests**: Test font sizing with various aspect ratios and screen sizes

### Step 2: Add Sub-Character Positioning
- [ ] Implement fractional position handling instead of integer truncation
- [ ] Use proper rounding for character grid positioning
- [ ] Add support for smooth entity movement between character positions
- [ ] Handle edge cases where entities are between character boundaries
- [ ] **Tests**: Verify fractional position mapping accuracy
- [ ] **Tests**: Test rounding behavior at character boundaries
- [ ] **Tests**: Validate smooth movement between grid positions
- [ ] **Tests**: Test edge cases (entities at exact boundaries, negative positions)

### Step 3: Implement Aspect Ratio Preservation
- [ ] Calculate the character grid dimensions to match the display aspect ratio
- [ ] Ensure the scene bounds match the actual character grid
- [ ] Add padding or scaling to maintain proper proportions
- [ ] Update the engine's scene dimensions to match the character grid
- [ ] **Tests**: Verify aspect ratio preservation across different screen sizes
- [ ] **Tests**: Test character grid dimensions match display bounds
- [ ] **Tests**: Validate padding/scaling calculations
- [ ] **Tests**: Test with extreme aspect ratios (very wide, very tall)

### Step 4: Add Real-Time Metrics Updates
- [ ] Make character metrics update when the display size changes
- [ ] Add callback system for when font size needs recalculation
- [ ] Ensure smooth transitions when resizing the display
- [ ] Cache metrics for performance while allowing updates
- [ ] **Tests**: Verify metrics update correctly on size changes
- [ ] **Tests**: Test callback system triggers appropriately
- [ ] **Tests**: Validate smooth transitions during resizing
- [ ] **Tests**: Test metrics caching performance and accuracy

### Step 5: Update Entity Movement System
- [ ] Modify entity positioning to work with the new character mapping
- [ ] Ensure smooth movement that respects character boundaries
- [ ] Update collision detection and screen wrapping logic
- [ ] Test that entities move smoothly across the improved grid
- [ ] **Tests**: Verify entity positioning accuracy with new mapping
- [ ] **Tests**: Test smooth movement across character boundaries
- [ ] **Tests**: Validate collision detection and screen wrapping
- [ ] **Tests**: Test entity movement with various speeds and directions

### Step 6: Integration Testing and Validation
- [ ] Test with different display sizes and aspect ratios
- [ ] Validate that characters align perfectly with the grid
- [ ] Ensure smooth animation without character "snapping"
- [ ] Test edge cases and boundary conditions
- [ ] **Tests**: End-to-end integration tests with various configurations
- [ ] **Tests**: Performance tests with many entities
- [ ] **Tests**: Stress tests with rapid size changes
- [ ] **Tests**: Visual regression tests for character alignment

## Current Issues
- Font scaling calculation inaccuracies
- Integer truncation causing character "snapping"
- Fixed scene dimensions not matching character grid
- Text rendering inconsistencies with calculated metrics

## Approach
Using improved font scaling with dynamic metrics to maintain the current text-based approach while fixing core positioning issues.

## Testing Strategy

### Test Categories
1. **Unit Tests**: Test individual functions and methods in isolation
2. **Integration Tests**: Test component interactions
3. **Performance Tests**: Ensure rendering remains smooth
4. **Visual Tests**: Validate character alignment and positioning

### Test Files to Create
- `AsciiquariumTests/ASCIIRendererTests.swift` - Test rendering logic
- `AsciiquariumTests/CharacterMappingTests.swift` - Test position mapping
- `AsciiquariumTests/FontMetricsTests.swift` - Test font calculations
- `AsciiquariumTests/EntityMovementTests.swift` - Test entity positioning
- `AsciiquariumTests/IntegrationTests.swift` - Test full system

### Key Test Scenarios
- Different screen sizes (320x240, 800x600, 1920x1080, 4K)
- Various aspect ratios (4:3, 16:9, 21:9, 1:1)
- Font size changes and dynamic resizing
- Entity movement across character boundaries
- Edge cases (zero size, negative positions, extreme values)

## Files to Modify
- `Shared/ASCIIRenderer.swift` - Main rendering logic
- `Shared/Engine.swift` - Scene dimensions and entity updates
- `AsciiquariumApp/ContentView.swift` - Display integration
- `Shared/Entity.swift` - Entity positioning logic (if needed)
- `AsciiquariumTests/` - Add comprehensive test coverage
