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

## Critical Issues Identified

### 1. Duplicate and Conflicting Calculation Methods
- **Problem**: Multiple implementations of character width/height calculations across files
- **Locations**: 
  - `ContentView.swift` (lines 146-196): Uses NSLayoutManager with 16-character test
  - `ASCIIRenderer.swift` (lines 24-42, 218-248): Uses size(withAttributes:) + font metrics
  - `Engine.swift` (lines 95-124): Duplicates NSLayoutManager approach
- **Impact**: Inconsistent results, maintenance nightmare
- **Priority**: HIGH

### 2. Inconsistent Font Size Handling
- **Problem**: Three different font sizes used simultaneously
- **Locations**:
  - `ContentView.swift`: Hardcoded 12.0pt
  - `ASCIIRenderer.swift`: 14.0pt in constructor, dynamic in calculateOptimalFontSize
  - `Engine.swift`: Uses passed-in font size
- **Impact**: Grid calculations don't match actual rendering
- **Priority**: HIGH

### 3. Broken Test Host Configuration
- **Problem**: Xcode project points to wrong app name
- **Current**: `Asciiquarium.app` 
- **Should be**: `AsciiquariumApp.app`
- **Impact**: Cannot run tests to validate fixes
- **Priority**: CRITICAL

### 4. Inefficient Grid Calculation Algorithm
- **Problem**: `calculateOptimalGridDimensions` only optimizes height, ignores width
- **Location**: `ASCIIRenderer.swift` lines 151-216
- **Impact**: Poor space utilization, suboptimal font sizing
- **Priority**: HIGH

### 5. Bounds vs Grid Mismatch
- **Problem**: ContentView calculates grid size differently than ASCIIRenderer
- **Impact**: Engine and renderer use different grid dimensions
- **Priority**: HIGH

### 6. Character Width Calculation Inconsistencies
- **Problem**: Different methods produce different results
- **Methods**:
  - `size(withAttributes:)` - Simple but potentially inaccurate
  - `NSLayoutManager` with 16-char test - Accurate but overcomplicated
  - `font.maximumAdvancement.width` - Fallback that may not match rendering
- **Priority**: MEDIUM

### 7. Missing Error Handling
- **Problem**: No validation for edge cases
- **Missing**: Zero/negative bounds, invalid font metrics, division by zero
- **Priority**: MEDIUM

### 8. Performance Issues
- **Problem**: Brute-force search on every bounds change
- **Impact**: Unnecessary CPU usage, poor responsiveness
- **Priority**: LOW

## Prioritized Action Plan

### Phase 1: Critical Fixes (Must Do First)

#### 1. Fix Test Host Configuration (CRITICAL) ✅
- [x] Update Xcode project to point to correct app name (`AsciiquariumApp.app`)
- [x] Verify tests can run successfully
- [x] Run existing test suite to establish baseline
- **Files**: `Asciiquarium.xcodeproj/project.pbxproj`

#### 2. Consolidate Character Calculation Methods (HIGH) ✅
- [x] Create new `Shared/FontMetrics.swift` utility class
- [x] Implement single, consistent character width calculation method
- [x] Implement single, consistent line height calculation method
- [x] Remove duplicate `calculateCharacterWidth` from `ContentView.swift`
- [x] Remove duplicate `calculateCharacterWidth` from `Engine.swift`
- [x] Remove duplicate `calculateLineHeight` from `Engine.swift`
- [x] Update `ASCIIRenderer.swift` to use new `FontMetrics` class
- [x] Update `ContentView.swift` to use new `FontMetrics` class
- [x] Update `Engine.swift` to use new `FontMetrics` class
- [x] Remove unnecessary `calculateOptimalGridDimensions` from `ASCIIRenderer`
- [x] Update `ContentView.swift` to use `FontMetrics` directly
- [x] Update all test files to use `FontMetrics` directly
- [x] Test that all files produce consistent results
- **Files**: ✅ Created `Shared/FontMetrics.swift`, updated all existing files

#### 3. Fix Font Size Consistency (HIGH)
- [ ] Remove hardcoded 12.0pt font size from `ContentView.swift`
- [ ] Remove hardcoded 14.0pt font size from `ASCIIRenderer.swift` constructor
- [ ] Establish single source of truth for font sizing in `FontMetrics` class
- [ ] Update `ContentView.swift` to use dynamic font sizing
- [ ] Update `ASCIIRenderer.swift` to use dynamic font sizing
- [ ] Update `Engine.swift` to use dynamic font sizing
- [ ] Verify all components use same font size
- **Files**: `ContentView.swift`, `ASCIIRenderer.swift`, `Engine.swift`

### Phase 2: Core Algorithm Fixes (HIGH Priority)

#### 4. Fix Grid Calculation Algorithm (HIGH)
- [ ] Analyze current `calculateOptimalGridDimensions` algorithm
- [ ] Implement width utilization optimization alongside height
- [ ] Replace brute-force search with efficient binary search or mathematical approach
- [ ] Add proper aspect ratio consideration to algorithm
- [ ] Add logging to verify optimization is working
- [ ] Test with various screen sizes and aspect ratios
- **Files**: `ASCIIRenderer.swift` - `calculateOptimalGridDimensions`

#### 5. Resolve Bounds vs Grid Mismatch (HIGH)
- [ ] Identify where ContentView and ASCIIRenderer calculate differently
- [ ] Ensure both use same `FontMetrics` calculations
- [ ] Synchronize grid dimensions between engine and renderer
- [ ] Add validation that calculated dimensions match
- [ ] Test that engine scene bounds match renderer grid
- [ ] Add logging to track dimension mismatches
- **Files**: `ContentView.swift`, `ASCIIRenderer.swift`, `Engine.swift`

### Phase 3: Robustness Improvements (MEDIUM Priority)

#### 6. Standardize Character Width Calculation (MEDIUM)
- [ ] Research and choose most accurate calculation method
- [ ] Implement chosen method in `FontMetrics` class
- [ ] Add proper fallback mechanisms
- [ ] Add validation for calculation results
- [ ] Add error handling for edge cases
- [ ] Test accuracy across different fonts and sizes
- **Files**: New `FontMetrics.swift`, update all calculation sites

#### 7. Add Comprehensive Error Handling (MEDIUM)
- [ ] Add bounds validation (zero, negative, infinite values)
- [ ] Add font metrics validation
- [ ] Add division by zero protection
- [ ] Add meaningful error messages and logging
- [ ] Add graceful degradation for invalid inputs
- [ ] Test error handling with edge case inputs
- **Files**: All calculation methods

### Phase 4: Performance Optimization (LOW Priority)

#### 8. Implement Caching and Performance Improvements (LOW)
- [ ] Add caching for font metric calculations
- [ ] Implement efficient grid calculation algorithm
- [ ] Add performance monitoring and logging
- [ ] Optimize font size search algorithm
- [ ] Add metrics for calculation performance
- [ ] Test performance with various screen sizes
- **Files**: `FontMetrics.swift`, `ASCIIRenderer.swift`

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
