# Fish Color Parity Plan: Perl to Swift

## Current State Analysis

### Perl Implementation

**Color Mask System:**
- Fish shapes come in pairs: `$fish_image[$fish_index]` (shape) and `$fish_image[$fish_index+1]` (color mask)
- Color mask uses numbers 1-9 to represent body parts:
  - `1`: body
  - `2`: dorsal fin
  - `3`: flippers
  - `4`: eye (replaced with 'W' white before randomization)
  - `5`: mouth
  - `6`: tailfin
  - `7`: gills
  - `8-9`: (not used in standard fish, but supported)

**Color Randomization:**
```perl
sub rand_color {
    my ($color_mask) = @_;
    my @colors = ('c','C','r','R','y','Y','b','B','g','G','m','M');
    foreach my $i (1..9) {
        my $color = $colors[int(rand($#colors))];
        $color_mask =~ s/$i/$color/gm;
    }
    return $color_mask;
}
```

**Process:**
1. Get color mask from fish image pair: `$fish_image[$fish_index+1]`
2. Replace all '4' (eye) with 'W' (white): `$color_mask =~ s/4/W/gm;`
3. Call `rand_color()` to replace each number (1-9) with random color
4. Each body part gets an independent random color

**Example color mask:**
```
       2
     1112111
6  11       1
 66     7  4 5
6  1      3 1
    11111311
```
After `rand_color()`:
```
       r
     cccrCcc
g  cc       c
 gg     m  W y
g  c      Y c
    ccccccYcc
```

### Swift Implementation

**Current State:**
- Fish use single-color masks with 'x' for opacity control
- `colorMask` uses 'x' = opaque, ' ' = transparent
- `defaultColor` is a single random color for entire fish
- Renderer already supports per-character colors from `colorMask` (lines 208-227 in ASCIIRenderer.swift)

**Renderer Support:**
- Lines 209-227: Already checks if `colorMask` character is a valid `ColorCode`
- If `colorCh` matches a `ColorCode.rawValue`, uses that color
- Falls back to `defaultColor` if not a valid color code

## Implementation Plan

### Step 1: Create Numbered Color Masks for Fish

**Action:** Update `FishEntity.setupRandomFishAppearance()` to generate color masks with numbers 1-7 for body parts, matching Perl's structure.

**Changes:**
- Replace current 'x'-based masks with numbered masks (1-7)
- Map body parts to numbers:
  - 1: body (main fish body)
  - 2: dorsal fin (top fin)
  - 3: flippers (side fins)
  - 4: eye (will be replaced with 'W' white)
  - 5: mouth
  - 6: tailfin
  - 7: gills

**Example:**
```swift
// Current:
let rightFacingMasks = [
    ["       x", "     xxxxxxx", ...]  // Single 'x' for opacity
]

// New:
let rightFacingMasks = [
    ["       2", "     1112111", "6  11       1", " 66     7  4 5", ...]  // Numbers for body parts
]
```

### Step 2: Implement `randomizeFishColors()` Function

**Action:** Create a function that replaces numbers 1-9 with random colors, matching Perl's `rand_color()`.

**Function:**
```swift
private func randomizeFishColors(colorMask: [String]) -> [String] {
    let colors: [ColorCode] = [.cyan, .cyanBright, .red, .redBright, .yellow, .yellowBright, 
                                .blue, .blueBright, .green, .greenBright, .magenta, .magentaBright]
    
    return colorMask.map { line in
        var result = line
        // Replace each number (1-9) with a random color
        for num in 1...9 {
            let numChar = Character("\(num)")
            let randomColor = colors.randomElement() ?? .cyan
            result = result.replacingOccurrences(of: String(numChar), with: String(randomColor.rawValue))
        }
        // Replace '4' (eye) with 'W' (white) - do this after randomization to ensure eye is white
        result = result.replacingOccurrences(of: "4", with: "W")
        return result
    }
}
```

**Note:** Actually, we need to replace '4' with 'W' BEFORE randomization, matching Perl's order.

### Step 3: Apply Color Randomization During Fish Initialization

**Action:** Call `randomizeFishColors()` in `setupRandomFishAppearance()` after selecting the base color mask.

**Process:**
1. Select base numbered color mask (1-7 for body parts)
2. Replace '4' with 'W' (eye = white)
3. Call `randomizeFishColors()` to replace numbers with random colors
4. Store result in `colorMask` property

### Step 4: Update Renderer (if needed)

**Action:** Verify renderer handles color codes correctly.

**Current Renderer:**
- Lines 217-220: Already checks if `colorCh` is a valid `ColorCode`
- Uses `ColorCode(rawValue: colorCh)` to convert character to color
- This should work with our randomized color masks!

**Potential Issue:**
- Need to ensure 'W' (white) is handled correctly
- Check if `ColorCode.white` has rawValue 'W' or 'w'

### Step 5: Handle Opacity vs Color

**Important Consideration:**
- Current system: `colorMask` controls both opacity AND color
  - Space = transparent (opacity)
  - Non-space = opaque + color
- New system: Need to maintain opacity while adding colors
  - Solution: Keep spaces for transparency
  - Use numbers/colors for opaque pixels with specific colors

**Implementation:**
- Color mask should have:
  - ` ` (space) = transparent pixel
  - `1-9` or color codes = opaque pixel with that color
- Renderer already handles this correctly (line 186: `shouldDraw = (maskCh != " ")`)

## Detailed Implementation Steps

### Phase 1: Create Numbered Color Masks

1. Extract color masks from Perl code for all fish shapes
2. Convert to Swift format with numbers 1-7 for body parts
3. Store as base templates (before randomization)

### Phase 2: Implement Randomization

1. Create `randomizeFishColors()` function
2. Replace '4' with 'W' first (eye = white)
3. Replace numbers 1-9 with random colors
4. Ensure each number gets independent random color

### Phase 3: Integration

1. Update `setupRandomFishAppearance()` to use numbered masks
2. Apply randomization
3. Store in `colorMask` property
4. Remove `defaultColor` usage (or keep as fallback)

### Phase 4: Testing

1. Verify each fish has different colors
2. Verify body parts have different colors
3. Verify eye is always white
4. Verify opacity still works (spaces remain transparent)

## Color Code Mapping

**Perl colors:** `('c','C','r','R','y','Y','b','B','g','G','m','M')`
**Swift ColorCode enum:**
- `c` → `.cyan`
- `C` → `.cyanBright`
- `r` → `.red`
- `R` → `.redBright`
- `y` → `.yellow`
- `Y` → `.yellowBright`
- `b` → `.blue`
- `B` → `.blueBright`
- `g` → `.green`
- `G` → `.greenBright`
- `m` → `.magenta`
- `M` → `.magentaBright`
- `W` → `.white` (for eyes)

## Acceptance Criteria

- [ ] Fish color masks use numbers 1-7 for body parts (matching Perl structure)
- [ ] Each body part gets a random color from the available color palette
- [ ] Eye (number 4) is always white ('W')
- [ ] Each fish has unique, randomized colors
- [ ] Opacity system still works (spaces remain transparent)
- [ ] Renderer correctly displays per-character colors
- [ ] Visual parity with Perl: fish have colorful, varied appearances

