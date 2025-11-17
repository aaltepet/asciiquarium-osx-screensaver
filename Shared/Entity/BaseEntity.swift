//
//  BaseEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

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

    // MARK: - Spawning Properties
    var spawnCallback: ((Entity) -> Void)?

    // MARK: - Collision Properties
    var isPhysical: Bool = false
    /// Collision handler receives: (self, [colliding entities])
    var collisionHandler: ((Entity, [Entity]) -> Void)?
    var collisionDepth: Int?

    // MARK: - Layout Properties
    var isFullWidth: Bool = false
    var isFullHeight: Bool = false

    // MARK: - Internal State
    var frameCount: Int = 0
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

        // Convert speed to grid-based movement (1 grid cell per second by default)
        let gridSpeed = speed * 30.0  // 30 FPS * 1 cell/second = 1 cell per frame
        let moveX = Int(gridSpeed * dx * deltaTime)
        let moveY = Int(gridSpeed * dy * deltaTime)
        let moveZ = Int(gridSpeed * dz * deltaTime)

        return Position3D(
            position.x + moveX,
            position.y + moveY,
            position.z + moveZ
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
        // Two-phase collision detection:
        // 1. Fast rejection: check bounding box overlap
        let myBounds = getBounds()
        let otherBounds = other.getBounds()

        guard myBounds.overlaps(with: otherBounds) else {
            return false
        }

        // 2. Accurate check: mask-based pixel-level collision
        // Special case: if either entity is full-width, use simplified check
        // (full-width entities span entire width, so just check Y overlap)
        if isFullWidth || (other as? BaseEntity)?.isFullWidth == true {
            // For full-width entities, if Y coordinates overlap, it's a collision
            // since they span the entire width
            let myTop = position.y
            let myBottom = position.y + size.height - 1
            let otherTop = other.position.y
            let otherBottom = other.position.y + other.size.height - 1
            return myTop <= otherBottom && myBottom >= otherTop
        }

        // For regular entities, use pixel-level mask collision
        let myPixels = getVisiblePixels()
        let otherPixels = (other as? BaseEntity)?.getVisiblePixels() ?? Set<IntPoint>()

        // Check if any pixels overlap
        return !myPixels.isDisjoint(with: otherPixels)
    }

    /// Get set of world coordinates for all visible pixels in this entity
    /// Uses colorMask if available, otherwise uses shape + transparentChar
    func getVisiblePixels() -> Set<IntPoint> {
        var pixels = Set<IntPoint>()

        // Determine which lines to use (mask or shape)
        let linesToCheck: [String]
        if let mask = colorMask {
            linesToCheck = mask
        } else {
            linesToCheck = shape
        }

        // Iterate through each line of the mask/shape
        for (rowIndex, line) in linesToCheck.enumerated() {
            let worldY = position.y + rowIndex

            // Iterate through each character in the line
            for (colIndex, char) in line.enumerated() {
                let worldX = position.x + colIndex

                // Determine if this pixel is visible
                let isVisible: Bool
                if colorMask != nil {
                    // In mask: space = transparent, non-space = visible
                    isVisible = (char != " ")
                } else {
                    // In shape: check against transparentChar
                    if let transparentChar = transparentChar {
                        isVisible = (char != transparentChar)
                    } else {
                        // Default: space is transparent
                        isVisible = (char != " ")
                    }
                }

                if isVisible {
                    pixels.insert(IntPoint(x: worldX, y: worldY))
                }
            }
        }

        return pixels
    }

    /// Get bounding box for collision detection
    /// Can be overridden by subclasses (e.g., EntityFullWidth for full-width entities)
    func getBounds() -> BoundingBox {
        return BoundingBox(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
    }

}
