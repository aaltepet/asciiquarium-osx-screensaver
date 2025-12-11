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
        case .fish(let position):
            return FishEntity(name: "fish_\(UUID().uuidString.prefix(8))", position: position)
        case .bubble(let position):
            return BubbleEntity(name: "bubble_\(UUID().uuidString.prefix(8))", position: position)
        case .shark(let position):
            return SharkEntity(name: "shark_\(UUID().uuidString.prefix(8))", position: position)
        case .waterline(let position, let segmentIndex):
            return WaterlineEntity(
                name: "waterline_\(UUID().uuidString.prefix(8))", position: position,
                segmentIndex: segmentIndex)
        case .castle(let position):
            return CastleEntity(name: "castle", position: position)
        case .seaweed(let position):
            return SeaweedEntity(name: "seaweed_\(UUID().uuidString.prefix(8))", position: position)
        case .ship(let position):
            return ShipEntity(name: "ship_\(UUID().uuidString.prefix(8))", position: position)
        case .whale(let position):
            return WhaleEntity(name: "whale_\(UUID().uuidString.prefix(8))", position: position)
        case .monster(let position):
            return MonsterEntity(name: "monster_\(UUID().uuidString.prefix(8))", position: position)
        case .bigFish(let position):
            return BigFishEntity(name: "bigfish_\(UUID().uuidString.prefix(8))", position: position)
        case .ducks(let position):
            return DucksEntity(name: "ducks_\(UUID().uuidString.prefix(8))", position: position)
        case .dolphins(let position):
            // Dolphins are created specially via spawnDolphins() in Engine
            // This is a fallback that shouldn't normally be used
            return DolphinEntity(
                name: "dolphin_\(UUID().uuidString.prefix(8))",
                position: position,
                direction: 1,
                pathOffset: 0,
                path: []
            )
        case .swan(let position):
            return SwanEntity(name: "swan_\(UUID().uuidString.prefix(8))", position: position)
        case .splat(let position):
            return SplatEntity(name: "splat_\(UUID().uuidString.prefix(8))", position: position)
        case .teeth(let position):
            return TeethEntity(name: "teeth_\(UUID().uuidString.prefix(8))", position: position)
        case .fishhook(let position):
            return FishhookEntity(
                name: "fishhook_\(UUID().uuidString.prefix(8))", position: position)
        case .fishline(let position):
            return FishlineEntity(
                name: "fishline_\(UUID().uuidString.prefix(8))", position: position)
        case .hookPoint(let position):
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

    static func createShark(at position: Position3D) -> SharkEntity {
        return SharkEntity(name: "shark_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createTeeth(at position: Position3D, speed: Double, direction: Int) -> TeethEntity {
        return TeethEntity(
            name: "teeth_\(UUID().uuidString.prefix(8))", position: position, speed: speed,
            direction: direction)
    }

    static func createSplat(at position: Position3D) -> SplatEntity {
        return SplatEntity(name: "splat_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createShip(at position: Position3D) -> ShipEntity {
        return ShipEntity(name: "ship_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createWhale(at position: Position3D) -> WhaleEntity {
        return WhaleEntity(name: "whale_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createMonster(at position: Position3D) -> MonsterEntity {
        return MonsterEntity(name: "monster_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createSwan(at position: Position3D) -> SwanEntity {
        return SwanEntity(name: "swan_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createDucks(at position: Position3D) -> DucksEntity {
        return DucksEntity(name: "ducks_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createBigFish(at position: Position3D) -> BigFishEntity {
        return BigFishEntity(name: "bigfish_\(UUID().uuidString.prefix(8))", position: position)
    }
}
