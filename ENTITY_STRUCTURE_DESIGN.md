# Swift Entity Structure Design

This document outlines the recommended structure for the Swift Entity base class based on the Perl asciiquarium entity properties.

## Core Entity Protocol/Base Class

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
protocol Entity: AnyObject {
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
    var callback: (() -> Void)? { get set }
    var callbackArgs: [Any]? { get set }
    
    // MARK: - Lifecycle Properties
    var dieOffscreen: Bool { get set }
    var dieTime: TimeInterval? { get set }
    var dieFrame: Int? { get set }
    var deathCallback: (() -> Void)? { get set }
    
    // MARK: - Collision Properties
    var isPhysical: Bool { get set }
    var collisionHandler: ((Entity) -> Void)? { get set }
    var collisionDepth: Int? { get set }
    
    // MARK: - Computed Properties
    var size: Size2D { get }
    var isAlive: Bool { get }
    
    // MARK: - Methods
    func update(deltaTime: TimeInterval)
    func kill()
    func moveEntity(deltaTime: TimeInterval) -> Position3D
    func checkCollisions(with entities: [Entity]) -> [Entity]
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
    var callback: (() -> Void)?
    var callbackArgs: [Any]?
    
    // MARK: - Lifecycle Properties
    var dieOffscreen: Bool = false
    var dieTime: TimeInterval?
    var dieFrame: Int?
    var deathCallback: (() -> Void)?
    
    // MARK: - Collision Properties
    var isPhysical: Bool = false
    var collisionHandler: ((Entity) -> Void)?
    var collisionDepth: Int?
    
    // MARK: - Internal State
    private var frameCount: Int = 0
    private var isKilled: Bool = false
    
    // MARK: - Computed Properties
    var size: Size2D {
        let maxWidth = shape.map { $0.count }.max() ?? 0
        return Size2D(maxWidth, shape.count)
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
        callback?()
        
        // Update position based on callback args
        if let newPosition = moveEntity(deltaTime: deltaTime) {
            position = newPosition
        }
    }
    
    func kill() {
        guard isAlive else { return }
        isKilled = true
        deathCallback?()
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
    
    func checkCollisions(with entities: [Entity]) -> [Entity] {
        guard isPhysical else { return [] }
        
        var collisions: [Entity] = []
        
        for entity in entities {
            guard entity.isPhysical && entity.id != id else { continue }
            
            if isColliding(with: entity) {
                collisions.append(entity)
            }
        }
        
        return collisions
    }
    
    private func isColliding(with other: Entity) -> Bool {
        // Simple bounding box collision detection
        let myBounds = getBounds()
        let otherBounds = other.getBounds()
        
        return myBounds.overlaps(with: otherBounds)
    }
    
    private func getBounds() -> BoundingBox {
        return BoundingBox(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
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
    static func createEntity(type: EntityType, name: String, position: Position3D) -> Entity {
        switch type {
        case .fish:
            return FishEntity(name: name, position: position)
        case .bubble:
            return BubbleEntity(name: name, position: position)
        case .shark:
            return SharkEntity(name: name, position: position)
        case .waterline:
            return WaterlineEntity(name: name, position: position)
        case .castle:
            return CastleEntity(name: name, position: position)
        case .seaweed:
            return SeaweedEntity(name: name, position: position)
        // Add other entity types as needed
        default:
            return BaseEntity(name: name, type: type, shape: [""], position: position)
        }
    }
}

// MARK: - Specific Entity Implementations
class FishEntity: BaseEntity {
    var speed: Double = 1.0
    var direction: Int = 1 // 1 for right, -1 for left
    
    init(name: String, position: Position3D) {
        super.init(name: name, type: .fish, shape: [""], position: position)
        setupFish()
    }
    
    private func setupFish() {
        // Set up fish-specific properties
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan
        callbackArgs = [speed, Double(direction), 0.0, 0.0]
    }
    
    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Fish-specific movement logic
        return Position3D(
            position.x + Int(speed * Double(direction) * deltaTime),
            position.y,
            position.z
        )
    }
}

class BubbleEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .bubble, shape: [".", "o", "O", "O", "O"], position: position)
        setupBubble()
    }
    
    private func setupBubble() {
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan
        callbackArgs = [0.0, 0.0, -1.0, 0.1] // Move upward
    }
    
    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Bubble rises upward
        return Position3D(
            position.x,
            position.y - 1,
            position.z
        )
    }
}

class SharkEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .shark, shape: [""], position: position)
        setupShark()
    }
    
    private func setupShark() {
        isPhysical = true
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [2.0, 1.0, 0.0, 0.0] // Fast horizontal movement
    }
}

class WaterlineEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .waterline, shape: ["~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"], position: position)
        setupWaterline()
    }
    
    private func setupWaterline() {
        isPhysical = true
        defaultColor = .cyan
        // Waterlines don't move
    }
    
    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil // Waterlines are static
    }
}

class CastleEntity: BaseEntity {
    init(name: String, position: Position3D) {
        let castleShape = [
            "               T~~",
            "               |",
            "              /^\\",
            "             /   \\",
            " _   _   _  /     \\  _   _   _",
            "[ ]_[ ]_[ ]/ _   _ \\[ ]_[ ]_[ ]",
            "|_=__-_ =_|_[ ]_[ ]_|_=-___-__|",
            " | _- =  | =_ = _    |= _=   |",
            " |= -[]  |- = _ =    |_-=_[] |",
            " | =_    |= - ___    | =_ =  |",
            " |=  []- |-  /| |\\   |=_ =[] |",
            " |- =_   | =| | | |  |- = -  |",
            " |_______|__|_|_|_|__|_______|"
        ]
        super.init(name: name, type: .castle, shape: castleShape, position: position)
        setupCastle()
    }
    
    private func setupCastle() {
        defaultColor = .black
        // Castle is static
    }
    
    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil // Castle is static
    }
}

class SeaweedEntity: BaseEntity {
    var swayDirection: Int = 1
    
    init(name: String, position: Position3D) {
        super.init(name: name, type: .seaweed, shape: [""], position: position)
        setupSeaweed()
    }
    
    private func setupSeaweed() {
        defaultColor = .green
        dieTime = Date().timeIntervalSince1970 + Double.random(in: 480...720) // 8-12 minutes
        callbackArgs = [0.0, 0.0, 0.0, 0.25] // Sway animation
    }
    
    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Seaweed sways but doesn't move position
        return nil
    }
}
```

## Key Design Decisions

### 1. **Protocol-Based Architecture**
- Uses `Entity` protocol for flexibility
- Allows different entity implementations
- Enables easy testing and mocking

### 2. **Value Types for Core Data**
- `Position3D` and `Size2D` as structs for performance
- Immutable when possible
- Clear separation of concerns

### 3. **Enum-Based Type System**
- `EntityType` enum for type safety
- `ColorCode` enum for color management
- Compile-time type checking

### 4. **Callback System**
- Function references for movement/animation
- Generic `callbackArgs` array for flexibility
- Death callbacks for entity replacement

### 5. **Collision Detection**
- Built-in collision system
- Bounding box-based detection
- Configurable collision depth

### 6. **Lifecycle Management**
- Multiple death conditions (time, frame, offscreen)
- Death callbacks for entity replacement
- Clean state management

### 7. **Factory Pattern**
- `EntityFactory` for creating entities
- Type-specific initialization
- Easy to extend with new entity types

### 8. **Swift-Specific Features**
- `UUID` for unique identification
- Optional types for optional properties
- Computed properties for derived values
- Memory management with `AnyObject` protocol

This structure provides a solid foundation for implementing the asciiquarium entities in Swift while maintaining the flexibility and functionality of the original Perl implementation.
