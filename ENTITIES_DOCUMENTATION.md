# Asciiquarium Entities Documentation

This document provides a comprehensive overview of all entities found in the original Perl asciiquarium source code.

## Table of Contents
- [Core Environment Entities](#core-environment-entities)
- [Fish & Marine Life](#fish--marine-life)
- [Surface & Above-Water Entities](#surface--above-water-entities)
- [Fishing Equipment](#fishing-equipment)
- [Particle Effects](#particle-effects)
- [Collision & Interaction Entities](#collision--interaction-entities)
- [Entity Depth Layering](#entity-depth-layering)
- [Random Object System](#random-object-system)
- [Entity Characteristics](#entity-characteristics)

## Core Environment Entities

### Water Surface & Environment

#### Water Lines (`waterline` type)
- **Purpose**: Creates the animated water surface with wave effects
- **Visual**: Uses `~` and `^` characters to simulate water waves
- **Layers**: 4 different water line segments (water_line0 through water_line3)
- **Animation**: Tiled across screen width, creates continuous wave motion
- **Depth**: Ranges from depth 2 to 8
- **Color**: Cyan
- **Collision**: Physical entities that bubbles collide with

#### Water Gaps
- **Purpose**: Provide spacing between water lines for depth layering
- **Depths**: water_gap0 (9), water_gap1 (7), water_gap2 (5), water_gap3 (3)
- **Function**: Allow entities to appear between water surface layers

### Aquarium Bottom

#### Castle
- **Purpose**: Main underwater structure providing visual anchor
- **Visual**: Detailed ASCII art castle with towers, windows, and battlements
- **Features**: 
  - Multiple towers with flags (`T~~`)
  - Windows and doors (`[ ]`, `_`)
  - Decorative elements (`=`, `-`, `|`)
- **Position**: Bottom-right corner of aquarium
- **Depth**: 22 (deepest layer)
- **Color**: Black with yellow and red accents
- **Size**: 32x13 characters

#### Seaweed
- **Purpose**: Animated underwater plants growing from bottom
- **Visual**: Swaying plant structures using `(` and `)` characters
- **Animation**: 
  - Alternating left/right swaying motion
  - Random height (3-6 characters tall)
  - Continuous regeneration (8-12 minute lifespan)
- **Generation**: Number based on screen width (1 per 15 characters)
- **Depth**: 21
- **Color**: Green
- **Behavior**: Self-replacing when it dies

## Fish & Marine Life

### Regular Fish (`fish` type)

#### Fish Varieties
The aquarium includes **20+ different fish shapes** with the following features:

**Fish Body Parts** (numbered in color masks):
1. **Body** - Main fish body
2. **Dorsal Fin** - Top fin
3. **Flippers** - Side fins
4. **Eye** - Fish eye (always colored white)
5. **Mouth** - Fish mouth
6. **Tailfin** - Rear fin
7. **Gills** - Gill slits

#### Fish Characteristics
- **Movement**: Horizontal swimming (left to right or right to left)
- **Speed**: Random speed between 0.25 and 2.25 units
- **Colors**: Random selection from cyan, red, yellow, blue, green, magenta (both light and dark variants)
- **Depth**: Random depth between 3-20 (fish_start to fish_end)
- **Behavior**: 
  - Continuous horizontal movement
  - 3% chance per frame to generate air bubbles
  - Collision detection with shark teeth and fishing hooks
  - Self-replacing when killed or moving off-screen
- **Population**: Based on screen size (1 fish per 350 screen units)

### Special Marine Creatures

#### Shark (`shark` type)
- **Purpose**: Predatory fish that hunts other fish
- **Visual**: Large detailed shark with teeth and fins
- **Features**:
  - Two directional variants (left and right facing)
  - Detailed body with gills and fins
  - Animated swimming motion
- **Behavior**:
  - Moves horizontally across screen
  - Has invisible "teeth" collision entity
  - Kills fish on contact
  - Generates blood splatter effects
- **Depth**: 2
- **Speed**: 2 units per frame
- **Color**: White with cyan accents

#### Big Fish
- **Purpose**: Large decorative fish
- **Visual**: Detailed fish with elaborate patterns
- **Features**:
  - Two directional variants
  - Complex body patterns and fins
  - Eye and mouth details
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: Same as shark (2)
- **Speed**: 3 units per frame
- **Color**: Yellow with random color accents

#### Whale
- **Purpose**: Large marine mammal
- **Visual**: Detailed whale with animated water spout
- **Features**:
  - Two directional variants
  - Animated water spout sequence (7 frames)
  - Large body with eye and mouth
- **Animation**:
  - 5 frames without spout
  - 7 frames with growing water spout
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap2 (5)
- **Speed**: 1 unit per frame
- **Color**: White with blue and cyan accents

#### Dolphins
- **Purpose**: Pod of marine mammals
- **Visual**: Three dolphins swimming in formation
- **Features**:
  - Two directional variants
  - Coordinated group movement
  - Animated swimming patterns
- **Behavior**:
  - Complex path following (up, glide, down, glide)
  - 15 frames up, 2 glide, 14 down, 6 glide
  - Staggered start times (0, 12, 24 frames)
  - Lead dolphin controls group death
- **Depth**: water_gap3 (3)
- **Speed**: Variable based on path
- **Color**: Blue variants (blue, BLUE, CYAN)

#### Monster
- **Purpose**: Sea monster with tentacles
- **Visual**: Large creature with multiple tentacles
- **Features**:
  - Two directional variants
  - 4-frame animation sequence
  - Tentacle movement patterns
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap2 (5)
- **Speed**: 2 units per frame
- **Color**: Green

## Surface & Above-Water Entities

### Boats & Ships

#### Ship
- **Purpose**: Sailing vessel on water surface
- **Visual**: Detailed ship with masts, sails, and hull
- **Features**:
  - Two directional variants
  - Multiple masts with sails
  - Detailed hull structure
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap1 (7)
- **Speed**: 1 unit per frame
- **Color**: White with yellow and white accents

### Waterfowl

#### Ducks
- **Purpose**: Flock of ducks swimming on surface
- **Visual**: Three ducks in formation
- **Features**:
  - Two directional variants
  - 3-frame animation (wing movement)
  - Coordinated group movement
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap3 (3)
- **Speed**: 1 unit per frame
- **Color**: White with green and yellow accents

#### Swan
- **Purpose**: Single swan on water surface
- **Visual**: Elegant swan with curved neck
- **Features**:
  - Two directional variants
  - Graceful neck and body curves
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap3 (3)
- **Speed**: 1 unit per frame
- **Color**: White with green and yellow accents

## Fishing Equipment

### Fishhook (`fishhook` type)
- **Purpose**: Fishing hook that can catch fish
- **Visual**: Detailed hook with line attachment
- **Features**:
  - Hook shape with eye
  - Fishing line connection
  - Collision detection point
- **Behavior**:
  - Lowers from surface to 75% of screen height
  - Can catch fish and reel them in
  - Self-replacing when off-screen
- **Depth**: water_line1 (6)
- **Color**: Green

### Fish Line (`fishline` type)
- **Purpose**: Fishing line attached to hook
- **Visual**: Vertical line of `|` characters
- **Features**:
  - 50-character long line
  - 6 spaces at bottom
- **Behavior**: Moves with hook, retracts when fish caught
- **Depth**: water_line1 (6)

### Hook Point (`hook_point` type)
- **Purpose**: Collision detection for fishing hook
- **Visual**: Small point (`.` and `\`)
- **Behavior**: Detects fish collisions, triggers hooking
- **Depth**: shark+1 (3)
- **Color**: Green

## Particle Effects

### Air Bubbles (`bubble` type)
- **Purpose**: Visual effect showing fish breathing
- **Visual**: Growing bubble sequence (`.`, `o`, `O`, `O`, `O`)
- **Behavior**:
  - Generated by fish (3% chance per frame)
  - Rises vertically at 0.1 speed
  - Pops when reaching waterline
  - Collision detection with water surface
- **Depth**: One level above generating fish
- **Color**: Cyan

### Splat Effects
- **Purpose**: Blood splatter when fish are eaten
- **Visual**: 4-frame blood splatter animation
- **Features**:
  - Random splatter patterns
  - Transparent background
  - 15-frame lifespan
- **Behavior**: Appears at collision point, fades out
- **Color**: Red
- **Transparency**: Space character

## Collision & Interaction Entities

### Shark Teeth (`teeth` type)
- **Purpose**: Invisible collision detection for shark attacks
- **Visual**: Single `*` character
- **Behavior**:
  - Moves with shark
  - Detects fish collisions
  - Triggers fish death and splat effect
- **Depth**: shark+1 (3)
- **Physical**: Yes (collision enabled)

## Entity Depth Layering

The aquarium uses a sophisticated Z-depth system for proper layering:

### Surface Level (Depths 2-9)
- **Depth 2**: water_line3, shark
- **Depth 3**: water_gap3, dolphins, ducks, swan
- **Depth 4**: water_line2
- **Depth 5**: water_gap2, whale, monster
- **Depth 6**: water_line1, fishhook, fishline
- **Depth 7**: water_gap1, ship
- **Depth 8**: water_line0
- **Depth 9**: water_gap0

### Underwater (Depths 3-22)
- **Depths 3-20**: Regular fish (random depth)
- **Depth 21**: Seaweed
- **Depth 22**: Castle, water lines (physical layer)

## Random Object System

The aquarium cycles through random objects to maintain variety:

### Random Object Functions
1. **add_ship** - Sailing ship
2. **add_whale** - Whale with water spout
3. **add_monster** - Sea monster
4. **add_big_fish** - Large decorative fish
5. **add_shark** - Predatory shark
6. **add_fishhook** - Fishing equipment
7. **add_swan** - Swan
8. **add_ducks** - Duck flock
9. **add_dolphins** - Dolphin pod

### Random Object Behavior
- **Selection**: Random choice from available functions
- **Timing**: Triggered when previous object dies or moves off-screen
- **Persistence**: Continuous cycling throughout aquarium life

## Entity Characteristics

### Common Properties
- **Position**: X, Y, Z coordinates
- **Shape**: ASCII art representation
- **Color**: Color mask for different body parts
- **Movement**: Callback-based animation
- **Lifespan**: Die off-screen or after time limit
- **Collision**: Physical entities can collide
- **Regeneration**: Many entities self-replace

### Color System
- **Body Colors**: c, C, r, R, y, Y, b, B, g, G, m, M
- **Special Colors**: W (white for eyes), specific colors for different body parts
- **Randomization**: Color masks are randomized for variety

### Animation System
- **Callback Functions**: Each entity has movement callbacks
- **Speed Control**: Variable speed based on entity type
- **Direction**: Left-to-right or right-to-left movement
- **Path Following**: Complex paths for dolphins and other creatures

### Collision Detection
- **Physical Entities**: Fish, bubbles, shark teeth, hook points
- **Collision Handlers**: Specific functions for different collision types
- **Death Triggers**: Collisions can cause entity death
- **Interaction**: Fish can be caught, eaten, or generate bubbles

This documentation provides a complete reference for implementing all entities found in the original asciiquarium Perl source code.
