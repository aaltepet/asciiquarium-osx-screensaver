import Foundation

class TeethEntity: BaseEntity {
    var speed: Double
    var direction: Int

    init(name: String, position: Position3D, speed: Double = 0.0, direction: Int = 1) {
        self.speed = speed
        self.direction = direction
        // Make teeth more visible for debugging - using "XXX" instead of "*"
        super.init(name: name, type: .teeth, shape: ["XXX"], position: position)

        isPhysical = true
        dieOffscreen = true
        defaultColor = .redBright  // Make it bright red so it's very visible
        // Note: For collision detection to work, teeth should be at Depth.shark + 1 (depth 3)
        // But we're using Depth.waterLine0 (depth 8) for visibility during debugging
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
