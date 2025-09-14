# Comprehensive Asciiquarium Entity Documentation

This document provides a complete reference for implementing the asciiquarium entities in Swift, combining detailed analysis of the original Perl source with the recommended Swift architecture.

## Table of Contents
- [Overview](#overview)
- [Entity Analysis from Perl Source](#entity-analysis-from-perl-source)
- [Swift Architecture Design](#swift-architecture-design)
- [Implementation Guidelines](#implementation-guidelines)

## Overview

The asciiquarium is a complex ASCII art animation featuring multiple types of entities that interact in a simulated underwater environment. This documentation covers both the analysis of the original Perl implementation and the recommended Swift architecture for recreating this system.

## Entity Analysis from Perl Source

### Core Environment Entities

#### Water Surface & Environment

##### Water Lines (`waterline` type)
- **Purpose**: Creates the animated water surface with wave effects
- **Visual**: Uses `~` and `^` characters to simulate water waves
- **Layers**: 4 different water line segments (water_line0 through water_line3)
- **Animation**: Tiled across screen width, creates continuous wave motion
- **Depth**: Ranges from depth 2 to 8
- **Color**: Cyan
- **Collision**: Physical entities that bubbles collide with

##### Water Gaps
- **Purpose**: Provide spacing between water lines for depth layering
- **Depths**: water_gap0 (9), water_gap1 (7), water_gap2 (5), water_gap3 (3)
- **Function**: Allow entities to appear between water surface layers

#### Aquarium Bottom

##### Castle
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

##### Seaweed
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

### Fish & Marine Life

#### Regular Fish (`fish` type)

##### Fish Varieties
The aquarium includes **20+ different fish shapes** with the following features:

**Fish Body Parts** (numbered in color masks):
1. **Body** - Main fish body
2. **Dorsal Fin** - Top fin
3. **Flippers** - Side fins
4. **Eye** - Fish eye (always colored white)
5. **Mouth** - Fish mouth
6. **Tailfin** - Rear fin
7. **Gills** - Gill slits

##### Fish Characteristics
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

#### Special Marine Creatures

##### Shark (`shark` type)
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

##### Big Fish
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

##### Whale
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

##### Dolphins
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

##### Monster
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

### Surface & Above-Water Entities

#### Boats & Ships

##### Ship
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

#### Waterfowl

##### Ducks
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

##### Swan
- **Purpose**: Single swan on water surface
- **Visual**: Elegant swan with curved neck
- **Features**:
  - Two directional variants
  - Graceful neck and body curves
- **Behavior**: Horizontal movement, self-replacing
- **Depth**: water_gap3 (3)
- **Speed**: 1 unit per frame
- **Color**: White with green and yellow accents

### Fishing Equipment

#### Fishhook (`fishhook` type)
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

#### Fish Line (`fishline` type)
- **Purpose**: Fishing line attached to hook
- **Visual**: Vertical line of `|` characters
- **Features**:
  - 50-character long line
  - 6 spaces at bottom
- **Behavior**: Moves with hook, retracts when fish caught
- **Depth**: water_line1 (6)

#### Hook Point (`hook_point` type)
- **Purpose**: Collision detection for fishing hook
- **Visual**: Small point (`.` and `\`)
- **Behavior**: Detects fish collisions, triggers hooking
- **Depth**: shark+1 (3)
- **Color**: Green

### Particle Effects

#### Air Bubbles (`bubble` type)
- **Purpose**: Visual effect showing fish breathing
- **Visual**: Growing bubble sequence (`.`, `o`, `O`, `O`, `O`)
- **Behavior**:
  - Generated by fish (3% chance per frame)
  - Rises vertically at 0.1 speed
  - Pops when reaching waterline
  - Collision detection with water surface
- **Depth**: One level above generating fish
- **Color**: Cyan

#### Splat Effects
- **Purpose**: Blood splatter when fish are eaten
- **Visual**: 4-frame blood splatter animation
- **Features**:
  - Random splatter patterns
  - Transparent background
  - 15-frame lifespan
- **Behavior**: Appears at collision point, fades out
- **Color**: Red
- **Transparency**: Space character

### Collision & Interaction Entities

#### Shark Teeth (`teeth` type)
- **Purpose**: Invisible collision detection for shark attacks
- **Visual**: Single `*` character
- **Behavior**:
  - Moves with shark
  - Detects fish collisions
  - Triggers fish death and splat effect
- **Depth**: shark+1 (3)
- **Physical**: Yes (collision enabled)

### Entity Depth Layering

The aquarium uses a sophisticated Z-depth system for proper layering:

#### Surface Level (Depths 2-9)
- **Depth 2**: water_line3, shark
- **Depth 3**: water_gap3, dolphins, ducks, swan
- **Depth 4**: water_line2
- **Depth 5**: water_gap2, whale, monster
- **Depth 6**: water_line1, fishhook, fishline
- **Depth 7**: water_gap1, ship
- **Depth 8**: water_line0
- **Depth 9**: water_gap0

#### Underwater (Depths 3-22)
- **Depths 3-20**: Regular fish (random depth)
- **Depth 21**: Seaweed
- **Depth 22**: Castle, water lines (physical layer)

### Random Object System

The aquarium cycles through random objects to maintain variety:

#### Random Object Functions
1. **add_ship** - Sailing ship
2. **add_whale** - Whale with water spout
3. **add_monster** - Sea monster
4. **add_big_fish** - Large decorative fish
5. **add_shark** - Predatory shark
6. **add_fishhook** - Fishing equipment
7. **add_swan** - Swan
8. **add_ducks** - Duck flock
9. **add_dolphins** - Dolphin pod

#### Random Object Behavior
- **Selection**: Random choice from available functions
- **Timing**: Triggered when previous object dies or moves off-screen
- **Persistence**: Continuous cycling throughout aquarium life

### Entity Characteristics

#### Common Properties
- **Position**: X, Y, Z coordinates
- **Shape**: ASCII art representation
- **Color**: Color mask for different body parts
- **Movement**: Callback-based animation
- **Lifespan**: Die off-screen or after time limit
- **Collision**: Physical entities can collide
- **Regeneration**: Many entities self-replace

#### Color System
- **Body Colors**: c, C, r, R, y, Y, b, B, g, G, m, M
- **Special Colors**: W (white for eyes), specific colors for different body parts
- **Randomization**: Color masks are randomized for variety

#### Animation System
- **Callback Functions**: Each entity has movement callbacks
- **Speed Control**: Variable speed based on entity type
- **Direction**: Left-to-right or right-to-left movement
- **Path Following**: Complex paths for dolphins and other creatures

#### Collision Detection
- **Physical Entities**: Fish, bubbles, shark teeth, hook points
- **Collision Handlers**: Specific functions for different collision types
- **Death Triggers**: Collisions can cause entity death
- **Interaction**: Fish can be caught, eaten, or generate bubbles

## Swift Architecture Design

### Core Entity Protocol/Base Class

```swift
import Foundation

// MARK: - Entity Types
enum EntityType: String, CaseIterable {
    case waterline = "waterline"
    case fish = "fish"
    case bubble = "bubble"
    case shark = "shark"
    case teeth = "teeth"
    case fishhook = "fishhook"
    case fishline = "fishline"
    case hookPoint = "hook_point"
    case castle = "castle"
    case seaweed = "seaweed"
    case ship = "ship"
    case whale = "whale"
    case monster = "monster"
    case bigFish = "big_fish"
    case ducks = "ducks"
    case dolphins = "dolphins"
    case swan = "swan"
}

// MARK: - Position and Size
struct Position3D {
    var x: Int
    var y: Int
    var z: Int
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct Size2D {
    var width: Int
    var height: Int
    
    init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
}

// MARK: - Color System
enum ColorCode: Character, CaseIterable {
    case cyan = "c"
    case cyanBright = "C"
    case red = "r"
    case redBright = "R"
    case yellow = "y"
    case yellowBright = "Y"
    case blue = "b"
    case blueBright = "B"
    case green = "g"
    case greenBright = "G"
    case magenta = "m"
    case magentaBright = "M"
    case white = "w"
    case whiteBright = "W"
    case black = "k"
    case blackBright = "K"
}

// MARK: - Entity Protocol
protocol Entity: AnyObject, Identifiable {
    // MARK: - Core Properties
    var id: UUID { get }
    var name: String { get set }
    var type: EntityType { get }
    var shape: [String] { get set }
    var position: Position3D { get set }
    
    // MARK: - Visual Properties
    var colorMask: [String]? { get set }
    var defaultColor: ColorCode { get set }
    var transparentChar: Character? { get set }
    var autoTransparent: Bool { get set }
    
    // MARK: - Behavioral Properties
    var callback: ((Entity, TimeInterval) -> Position3D?)? { get set }
    var callbackArgs: [Any]? { get set }
    
    // MARK: - Lifecycle Properties
    var dieOffscreen: Bool { get set }
    var dieTime: TimeInterval? { get set }
    var dieFrame: Int? { get set }
    var deathCallback: ((Entity) -> Void)? { get set }
    
    // MARK: - Collision Properties
    var isPhysical: Bool { get set }
    var collisionHandler: ((Entity, [Entity]) -> Void)? { get set }
    var depth: Int { get set }
    
    // MARK: - Computed Properties
    var size: Size2D { get }
    var boundingBox: BoundingBox { get }
    var isAlive: Bool { get }
    
    // MARK: - Methods
    func update(deltaTime: TimeInterval)
    func moveEntity(deltaTime: TimeInterval) -> Position3D?
    func checkCollisions(with otherEntities: [Entity]) -> [Entity]
    func kill()
}

// MARK: - Base Entity Implementation
class BaseEntity: Entity {
    // MARK: - Core Properties
    let id = UUID()
    var name: String
    let type: EntityType
    var shape: [String]
    var position: Position3D
    
    // MARK: - Visual Properties
    var colorMask: [String]?
    var defaultColor: ColorCode = .white
    var transparentChar: Character? = " "
    var autoTransparent: Bool = false
    
    // MARK: - Behavioral Properties
    var callback: ((Entity, TimeInterval) -> Position3D?)?
    var callbackArgs: [Any]?
    
    // MARK: - Lifecycle Properties
    var dieOffscreen: Bool = false
    var dieTime: TimeInterval?
    var dieFrame: Int?
    var deathCallback: ((Entity) -> Void)?
    
    // MARK: - Collision Properties
    var isPhysical: Bool = false
    var collisionHandler: ((Entity, [Entity]) -> Void)?
    var depth: Int = 0
    
    // MARK: - Internal State
    var frameCount: Int = 0
    private var isKilled: Bool = false
    
    // MARK: - Computed Properties
    var size: Size2D {
        let maxWidth = shape.map { $0.count }.max() ?? 0
        return Size2D(maxWidth, shape.count)
    }
    
    var boundingBox: BoundingBox {
        return BoundingBox(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
    }
    
    var isAlive: Bool {
        return !isKilled
    }
    
    // MARK: - Initialization
    init(name: String, type: EntityType, shape: [String], position: Position3D) {
        self.name = name
        self.type = type
        self.shape = shape
        self.position = position
    }
    
    // MARK: - Methods
    func update(deltaTime: TimeInterval) {
        guard isAlive else { return }
        
        frameCount += 1
        
        // Check death conditions
        if let dieTime = dieTime, Date().timeIntervalSince1970 >= dieTime {
            kill()
            return
        }
        
        if let dieFrame = dieFrame, frameCount >= dieFrame {
            kill()
            return
        }
        
        // Execute callback
        if let newPosition = callback?(self, deltaTime) {
            position = newPosition
        } else if let newPosition = moveEntity(deltaTime: deltaTime) {
            position = newPosition
        }
    }
    
    func kill() {
        guard isAlive else { return }
        isKilled = true
        deathCallback?(self)
    }
    
    func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Default implementation - override in subclasses
        guard let args = callbackArgs, args.count >= 3 else { return nil }
        
        let speed = args[0] as? Double ?? 0.0
        let dx = args[1] as? Double ?? 0.0
        let dy = args[2] as? Double ?? 0.0
        let dz = args.count > 3 ? (args[3] as? Double ?? 0.0) : 0.0
        
        return Position3D(
            position.x + Int(speed * dx * deltaTime),
            position.y + Int(speed * dy * deltaTime),
            position.z + Int(speed * dz * deltaTime)
        )
    }
    
    func checkCollisions(with otherEntities: [Entity]) -> [Entity] {
        guard isPhysical else { return [] }
        
        var collisions: [Entity] = []
        
        for entity in otherEntities {
            guard entity.isPhysical && entity.id != id else { continue }
            
            if boundingBox.overlaps(with: entity.boundingBox) {
                collisions.append(entity)
            }
        }
        
        return collisions
    }
}

// MARK: - Supporting Types
struct BoundingBox {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    func overlaps(with other: BoundingBox) -> Bool {
        return x < other.x + other.width &&
               x + width > other.x &&
               y < other.y + other.height &&
               y + height > other.y
    }
}

// MARK: - Entity Factory
class EntityFactory {
    static func createFish(at position: Position3D) -> Entity {
        return FishEntity(name: "fish_\(UUID().uuidString.prefix(8))", position: position)
    }
    
    static func createBubble(at position: Position3D) -> Entity {
        return BubbleEntity(name: "bubble_\(UUID().uuidString.prefix(8))", position: position)
    }
    
    static func createShark(at position: Position3D) -> Entity {
        return SharkEntity(name: "shark_\(UUID().uuidString.prefix(8))", position: position)
    }
    
    static func createWaterline(at position: Position3D, segmentIndex: Int) -> Entity {
        return WaterlineEntity(name: "waterline_\(segmentIndex)", position: position, segmentIndex: segmentIndex)
    }
    
    static func createCastle(at position: Position3D) -> Entity {
        return CastleEntity(name: "castle", position: position)
    }
    
    static func createSeaweed(at position: Position3D) -> Entity {
        return SeaweedEntity(name: "seaweed_\(UUID().uuidString.prefix(8))", position: position)
    }
    
    // Add other entity creation methods as needed
}
```

### Key Design Decisions

#### 1. **Protocol-Based Architecture**
- Uses `Entity` protocol for flexibility
- Allows different entity implementations
- Enables easy testing and mocking

#### 2. **Value Types for Core Data**
- `Position3D` and `Size2D` as structs for performance
- Immutable when possible
- Clear separation of concerns

#### 3. **Enum-Based Type System**
- `EntityType` enum for type safety
- `ColorCode` enum for color management
- Compile-time type checking

#### 4. **Callback System**
- Function references for movement/animation
- Generic `callbackArgs` array for flexibility
- Death callbacks for entity replacement

#### 5. **Collision Detection**
- Built-in collision system
- Bounding box-based detection
- Configurable collision depth

#### 6. **Lifecycle Management**
- Multiple death conditions (time, frame, offscreen)
- Death callbacks for entity replacement
- Clean state management

#### 7. **Factory Pattern**
- `EntityFactory` for creating entities
- Type-specific initialization
- Easy to extend with new entity types

#### 8. **Swift-Specific Features**
- `UUID` for unique identification
- Optional types for optional properties
- Computed properties for derived values
- Memory management with `AnyObject` protocol

## Implementation Guidelines

### File Organization
```
Shared/Entity/
├── EntityTypes.swift          # Core types and enums
├── EntityProtocol.swift       # Entity protocol definition
├── BaseEntity.swift          # Base implementation
├── EntityFactory.swift       # Entity creation
└── Entities/                 # Specific entity implementations
    ├── FishEntity.swift
    ├── BubbleEntity.swift
    ├── WaterlineEntity.swift
    ├── CastleEntity.swift
    ├── SeaweedEntity.swift
    ├── SharkEntity.swift
    └── PlaceholderEntities.swift
```

### Implementation Priorities

1. **Core System** - Entity protocol, BaseEntity, EntityFactory
2. **Environment** - Waterline, Castle, Seaweed
3. **Marine Life** - Fish, Bubbles, Shark
4. **Surface Entities** - Ship, Ducks, Swan
5. **Special Effects** - Splat, Monster, Whale
6. **Advanced Features** - Dolphins, Fishing equipment

### Testing Strategy

- Unit tests for each entity type
- Integration tests for collision detection
- Performance tests for large entity counts
- Visual regression tests for rendering

### Performance Considerations

- Use value types for position and size data
- Implement object pooling for frequently created/destroyed entities
- Optimize collision detection with spatial partitioning
- Cache computed properties where appropriate

This comprehensive documentation provides everything needed to implement a full-featured asciiquarium in Swift while maintaining the charm and complexity of the original Perl version.
