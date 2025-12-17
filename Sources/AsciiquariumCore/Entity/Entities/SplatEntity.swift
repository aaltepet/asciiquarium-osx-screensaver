//
//  SplatEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Splat Entity
public class SplatEntity: BaseEntity {
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

    public init(name: String, position: Position3D) {
        // Start with first frame
        super.init(name: name, type: .splat, shape: SplatEntity.splatFrames[0], position: position)
        setupSplat()
    }

    private func setupSplat() {
        defaultColor = .red
        transparentChar = " "  // Spaces are transparent
        dieFrame = 15  // Dies after 15 frames (matching Perl: die_frame => 15)
    }

    public override func update(deltaTime: TimeInterval) {
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
