import Foundation

public class TeethEntity: BaseEntity {
    public var speed: Double
    public var direction: Int

    public init(name: String, position: Position3D, speed: Double = 0.0, direction: Int = 1) {
        self.speed = speed
        self.direction = direction
        // Make teeth more visible for debugging - using "XXX" instead of "*"
        super.init(name: name, type: .teeth, shape: ["***"], position: position)

        isPhysical = true
        dieOffscreen = false  // Teeth should not die off-screen - they stay with the shark
        // Teeth will be killed when the shark dies (via shark's death callback)
        defaultColor = .redBright  // Make it bright red so it's very visible
        // Teeth are at Depth.shark - 1 (depth 1) to render behind the shark
        // Collision detection doesn't check depth (only X/Y), so this works fine
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
