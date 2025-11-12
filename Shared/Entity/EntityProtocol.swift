//
//  EntityProtocol.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

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

    // MARK: - Spawning Properties
    var spawnCallback: ((Entity) -> Void)? { get set }

    // MARK: - Collision Properties
    var isPhysical: Bool { get set }
    var collisionHandler: ((Entity) -> Void)? { get set }
    var collisionDepth: Int? { get set }

    // MARK: - Layout Properties
    var isFullWidth: Bool { get set }
    var isFullHeight: Bool { get set }

    // MARK: - Computed Properties
    var size: Size2D { get }
    var isAlive: Bool { get }

    // MARK: - Methods
    func update(deltaTime: TimeInterval)
    func kill()
    func moveEntity(deltaTime: TimeInterval) -> Position3D?
    func checkCollisions(with entities: [Entity]) -> [Entity]
}
