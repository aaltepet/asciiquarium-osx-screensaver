//
//  EntityFullWidth.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Full-Width Entity Base Class
class EntityFullWidth: BaseEntity {

    override init(name: String, type: EntityType, shape: [String], position: Position3D) {
        super.init(name: name, type: type, shape: shape, position: position)
        isFullWidth = true
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil  // Waterlines are static
    }

    // MARK: - Full-Width Entity Methods

    /// Generate current shape for the specified width (allows for dynamic/random generation)
    /// Override this method in subclasses to provide dynamic behavior
    func getShape(for width: Int) -> [String] {
        // Default implementation just uses static tiling
        return shape.map { shapeLine in
            let repeatCount = (width / shapeLine.count) + 1
            let tiledShape = String(repeating: shapeLine, count: repeatCount)
            return String(tiledShape.prefix(width))
        }
    }

    // MARK: - Override Bounds for Collision Detection

    /// Override getBounds to return full-width bounding box for collision detection
    /// Full-width entities span the entire grid width, so we use a very large width
    /// to ensure collisions are detected correctly
    override func getBounds() -> BoundingBox {
        // Full-width entities span from x=0 to x=gridWidth (or beyond)
        // Use a very large width (10000) to ensure collision detection works
        // This is safe because waterlines are at x=0 and span the full width
        return BoundingBox(
            x: position.x,
            y: position.y,
            width: 10000,  // Very large width for full-width entities
            height: size.height
        )
    }
}
