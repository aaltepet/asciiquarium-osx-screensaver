//
//  EntityTypes.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Entity Types
public enum EntityType: String, CaseIterable {
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
    case splat = "splat"
}

// MARK: - Position and Size
/// Represents a position in the ASCII character grid (not pixel coordinates)
/// - x: Column position (0 = leftmost column)
/// - y: Row position (0 = topmost row)
/// - z: Depth/layer for rendering order (higher z = rendered on top)
public struct Position3D: Equatable {
    public var x: Int
    public var y: Int
    public var z: Int

    public init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = Int(x)
        self.y = Int(y)
        self.z = Int(z)
    }
}

public struct Size2D: Equatable {
    public var width: Int
    public var height: Int

    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
}

// MARK: - Color System
public enum ColorCode: Character, CaseIterable {
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

// MARK: - Point for Pixel-Level Collision Detection
public struct IntPoint: Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

// MARK: - Bounding Box for Collision Detection
public struct BoundingBox: Equatable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public func overlaps(with other: BoundingBox) -> Bool {
        return x < other.x + other.width && x + width > other.x && y < other.y + other.height
            && y + height > other.y
    }
}
