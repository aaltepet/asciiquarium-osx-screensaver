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
}
