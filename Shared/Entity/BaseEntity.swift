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
    // Optional alpha mask (same dimensions as shape). Any non-space in the mask
    // indicates an opaque pixel even if the shape character is a space.
    var alphaMask: [String]?
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

// MARK: - Entity Extension for Bounds
extension Entity {
    func getBounds() -> BoundingBox {
        return BoundingBox(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
    }
}
