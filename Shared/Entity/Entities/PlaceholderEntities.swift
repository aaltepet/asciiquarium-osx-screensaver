//
//  PlaceholderEntities.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Placeholder Entities (to be implemented)

class ShipEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .ship, shape: [""], position: position)
        setupShip()
    }

    private func setupShip() {
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [1.0, 1.0, 0.0, 0.0]
    }
}

class WhaleEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .whale, shape: [""], position: position)
        setupWhale()
    }

    private func setupWhale() {
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [1.0, 1.0, 0.0, 0.0]
    }
}

class MonsterEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .monster, shape: [""], position: position)
        setupMonster()
    }

    private func setupMonster() {
        dieOffscreen = true
        defaultColor = .green
        callbackArgs = [2.0, 1.0, 0.0, 0.25]
    }
}

class BigFishEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .bigFish, shape: [""], position: position)
        setupBigFish()
    }

    private func setupBigFish() {
        dieOffscreen = true
        defaultColor = .yellow
        callbackArgs = [3.0, 1.0, 0.0, 0.0]
    }
}

class DucksEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .ducks, shape: [""], position: position)
        setupDucks()
    }

    private func setupDucks() {
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [1.0, 1.0, 0.0, 0.25]
    }
}

class DolphinsEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .dolphins, shape: [""], position: position)
        setupDolphins()
    }

    private func setupDolphins() {
        dieOffscreen = true
        defaultColor = .blue
        callbackArgs = [1.0, 1.0, 0.0, 0.5]
    }
}

class SwanEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .swan, shape: [""], position: position)
        setupSwan()
    }

    private func setupSwan() {
        dieOffscreen = true
        defaultColor = .white
        callbackArgs = [1.0, 1.0, 0.0, 0.25]
    }
}

class SplatEntity: BaseEntity {
    private var animationFrame: Int = 0

    // Splat animation frames (matching Perl: 4 frames that cycle)
    private static let splatFrames = [
        [
            "   .",
            "  ***",
            "   '",
        ],
        [
            " \",*;`",
            " \"*,**",
            " *\"'~'",
        ],
        [
            "  , ,",
            " \" \",\"'",
            " *\" *'\"",
            "  \" ; .",
        ],
        [
            "* ' , ' `",
            "' ` * . '",
            " ' `' \",'",
            "* ' \" * .",
            "\" * ', '",
        ],
    ]

    init(name: String, position: Position3D) {
        // Start with first frame
        super.init(name: name, type: .splat, shape: SplatEntity.splatFrames[0], position: position)
        setupSplat()
    }

    private func setupSplat() {
        defaultColor = .red
        transparentChar = " "  // Spaces are transparent
        dieFrame = 15  // Dies after 15 frames (matching Perl: die_frame => 15)
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Animate splat growth (cycle through frames)
        if frameCount < SplatEntity.splatFrames.count {
            shape = SplatEntity.splatFrames[frameCount]
        } else {
            // After all frames, keep last frame
            shape = SplatEntity.splatFrames.last ?? SplatEntity.splatFrames[0]
        }
    }
}

class TeethEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .teeth, shape: ["*"], position: position)
        setupTeeth()
    }

    private func setupTeeth() {
        isPhysical = true
        defaultColor = .white
        callbackArgs = [2.0, 1.0, 0.0, 0.0]
    }
}

class FishhookEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .fishhook, shape: [""], position: position)
        setupFishhook()
    }

    private func setupFishhook() {
        dieOffscreen = true
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]  // Lowering motion
    }
}

class FishlineEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .fishline, shape: [""], position: position)
        setupFishline()
    }

    private func setupFishline() {
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]
    }
}

class HookPointEntity: BaseEntity {
    init(name: String, position: Position3D) {
        super.init(name: name, type: .hookPoint, shape: [".", "\\"], position: position)
        setupHookPoint()
    }

    private func setupHookPoint() {
        isPhysical = true
        defaultColor = .green
        callbackArgs = [0.0, 0.0, 1.0, 0.0]
    }
}
