//
//  EntityFactory.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Entity Factory
class EntityFactory {

    // MARK: - Discriminated Union for Entity Construction
    enum EntitySpec {
        case fish(position: Position3D)
        case bubble(position: Position3D)
        case shark(position: Position3D)
        case waterline(position: Position3D, segmentIndex: Int)
        case castle(position: Position3D)
        case seaweed(position: Position3D)
        case ship(position: Position3D)
        case whale(position: Position3D)
        case monster(position: Position3D)
        case bigFish(position: Position3D)
        case ducks(position: Position3D)
        case dolphins(position: Position3D)
        case swan(position: Position3D)
        case splat(position: Position3D)
        case teeth(position: Position3D)
        case fishhook(position: Position3D)
        case fishline(position: Position3D)
        case hookPoint(position: Position3D)
    }

    static func create(from spec: EntitySpec) -> Entity {
        switch spec {
        case let .fish(position):
            return FishEntity(name: "fish_\(UUID().uuidString.prefix(8))", position: position)
        case let .bubble(position):
            return BubbleEntity(name: "bubble_\(UUID().uuidString.prefix(8))", position: position)
        case let .shark(position):
            return SharkEntity(name: "shark_\(UUID().uuidString.prefix(8))", position: position)
        case let .waterline(position, segmentIndex):
            return WaterlineEntity(
                name: "waterline_\(UUID().uuidString.prefix(8))", position: position,
                segmentIndex: segmentIndex)
        case let .castle(position):
            return CastleEntity(name: "castle", position: position)
        case let .seaweed(position):
            return SeaweedEntity(name: "seaweed_\(UUID().uuidString.prefix(8))", position: position)
        case let .ship(position):
            return ShipEntity(name: "ship_\(UUID().uuidString.prefix(8))", position: position)
        case let .whale(position):
            return WhaleEntity(name: "whale_\(UUID().uuidString.prefix(8))", position: position)
        case let .monster(position):
            return MonsterEntity(name: "monster_\(UUID().uuidString.prefix(8))", position: position)
        case let .bigFish(position):
            return BigFishEntity(name: "bigfish_\(UUID().uuidString.prefix(8))", position: position)
        case let .ducks(position):
            return DucksEntity(name: "ducks_\(UUID().uuidString.prefix(8))", position: position)
        case let .dolphins(position):
            return DolphinsEntity(
                name: "dolphins_\(UUID().uuidString.prefix(8))", position: position)
        case let .swan(position):
            return SwanEntity(name: "swan_\(UUID().uuidString.prefix(8))", position: position)
        case let .splat(position):
            return SplatEntity(name: "splat_\(UUID().uuidString.prefix(8))", position: position)
        case let .teeth(position):
            return TeethEntity(name: "teeth_\(UUID().uuidString.prefix(8))", position: position)
        case let .fishhook(position):
            return FishhookEntity(
                name: "fishhook_\(UUID().uuidString.prefix(8))", position: position)
        case let .fishline(position):
            return FishlineEntity(
                name: "fishline_\(UUID().uuidString.prefix(8))", position: position)
        case let .hookPoint(position):
            return HookPointEntity(
                name: "hookpoint_\(UUID().uuidString.prefix(8))", position: position)
        }
    }

    // MARK: - Convenience Methods
    static func createFish(at position: Position3D) -> FishEntity {
        return FishEntity(name: "fish_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createBubble(at position: Position3D) -> BubbleEntity {
        return BubbleEntity(name: "bubble_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createWaterline(at position: Position3D, segmentIndex: Int) -> WaterlineEntity {
        return WaterlineEntity(
            name: "waterline_\(UUID().uuidString.prefix(8))", position: position,
            segmentIndex: segmentIndex)
    }

    static func createCastle(at position: Position3D) -> CastleEntity {
        return CastleEntity(name: "castle", position: position)
    }

    static func createSeaweed(at position: Position3D) -> SeaweedEntity {
        return SeaweedEntity(name: "seaweed_\(UUID().uuidString.prefix(8))", position: position)
    }
}
