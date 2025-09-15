//
//  EntityFactory.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Entity Factory
class EntityFactory {
    static func createEntity(
        type: EntityType, name: String, position: Position3D, additionalParams: [String: Any] = [:]
    ) -> Entity {
        switch type {
        case .fish:
            return FishEntity(name: name, position: position)
        case .bubble:
            return BubbleEntity(name: name, position: position)
        case .shark:
            return SharkEntity(name: name, position: position)
        case .waterline:
            let segmentIndex = additionalParams["segmentIndex"] as? Int ?? 0
            return WaterlineEntity(name: name, position: position, segmentIndex: segmentIndex)
        case .castle:
            return CastleEntity(name: name, position: position)
        case .seaweed:
            return SeaweedEntity(name: name, position: position)
        case .ship:
            return ShipEntity(name: name, position: position)
        case .whale:
            return WhaleEntity(name: name, position: position)
        case .monster:
            return MonsterEntity(name: name, position: position)
        case .bigFish:
            return BigFishEntity(name: name, position: position)
        case .ducks:
            return DucksEntity(name: name, position: position)
        case .dolphins:
            return DolphinsEntity(name: name, position: position)
        case .swan:
            return SwanEntity(name: name, position: position)
        case .teeth:
            return TeethEntity(name: name, position: position)
        case .fishhook:
            return FishhookEntity(name: name, position: position)
        case .fishline:
            return FishlineEntity(name: name, position: position)
        case .hookPoint:
            return HookPointEntity(name: name, position: position)
        }
    }

    // MARK: - Convenience Methods
    static func createFish(at position: Position3D) -> FishEntity {
        return FishEntity(name: "fish_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createBubble(at position: Position3D) -> BubbleEntity {
        return BubbleEntity(name: "bubble_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createWaterline(at position: Position3D)
        -> WaterlineEntity
    {
        return WaterlineEntity(
            name: "waterline_\(UUID().uuidString.prefix(8))", position: position)
    }

    static func createCastle(at position: Position3D) -> CastleEntity {
        return CastleEntity(name: "castle", position: position)
    }

    static func createSeaweed(at position: Position3D) -> SeaweedEntity {
        return SeaweedEntity(name: "seaweed_\(UUID().uuidString.prefix(8))", position: position)
    }
}
