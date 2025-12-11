import Foundation

class TeethEntity: BaseEntity {
    var speed: Double
    var direction: Int

    init(name: String, position: Position3D, speed: Double = 0.0, direction: Int = 1) {
        self.speed = speed
        self.direction = direction
        super.init(name: name, type: .teeth, shape: ["*"], position: position)

        isPhysical = true
        dieOffscreen = true
        callbackArgs = [speed, Double(direction), 0.0, 0.0]

        // The teeth are the aggressor; they handle the collision.
        collisionHandler = { [weak self] (teeth, collisions) in
            guard let self = self else { return }

            for entity in collisions {
                // Check if we collided with a fish
                if entity is FishEntity {
                    // Spawn a splat at the fish's position
                    if let spawnCallback = self.spawnCallback {
                        let splat = EntityFactory.createSplat(at: entity.position)
                        spawnCallback(splat)
                    }
                    // Kill the fish
                    entity.kill()
                }
            }
        }
    }
}
