//
//  SharkEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Shark Entity
class SharkEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 1.6  // Speed matching Perl: $speed = 2

    // Shark shapes (left and right facing) - matching Perl
    private static let sharkShapeRight = [
        "                              __",
        "                             ( `\\",
        "  ,                          )   `\\",
        ";' `.                        (     `\\__",
        " ;   `.             __..---''          `~~~~-._",
        "  `.   `.____...--''                       (b  `--._",
        "    >                     _.-'      .((      ._     )",
        "  .`.-`--...__         .-'     -.___.....-(|/|/|/|/'",
        " ;.'         `. ...----`.___.',,,_______......---'",
        " '           '-'",
    ]

    private static let sharkShapeLeft = [
        "                     __",
        "                    /' )",
        "                  /'   (                          ,",
        "              __/'     )                        .' `;",
        "      _.-~~~~'          ``---..__             .'   ;",
        " _.--'  b)                       ``--...____.'   .'",
        "(     _.      )).      `-._                     <",
        " `\\|\\|\\|\\|)-.....___.-     `-.         __...--'-.'.",
        "   `---......_______,,,`.___.'----... .'         `.;",
        "                                     `-`           `",
    ]

    // Shark color masks (matching Perl: @shark_mask)
    // Spaces in mask = transparent, color codes = visible
    // 'c' = cyan, 'R' = red, 'W' = white
    private static let sharkMaskRight = [
        "                              __",
        "                             (x`\\",
        "  ,                          )xxx`\\",
        ";'x`.                        (xxxxx`\\__",
        " ;xxx`.             __..---''xxxxxxxxxx`~~~~-._",
        "  `.xxx`.____...--''xxxxxxxxxxxxxxxxxxxxxxxcRxx`--._",
        "    >xxxxxxxxxxxxxxxxxxxxx_.-'xxxxxx.((xxxxxx._xxxxx)",
        "  .`.-`--...__xxxxxxxxx.-'xxxxx-.___.....-cWWWWWWWW'",
        " ;.'         `.x...----`.___.',,,_______......---'",
        " '           '-'",
    ]

    private static let sharkMaskLeft = [
        "                     __",
        "                    /'x)",
        "                  /'xxx(                          ,",
        "              __/'xxxxx)                        .'x`;",
        "      _.-~~~~'xxxxxxxxxx``---..__             .'xxx;",
        " _.--'xxRcxxxxxxxxxxxxxxxxxxxxxxx``--...____.'xxx.'",
        "(xxxxx_.xxxxxx)).xxxxxx`-._xxxxxxxxxxxxxxxxxxxxx<",
        " `WWWWWWWWc-.....___.-xxxxx`-.xxxxxxxxx__...--'-.'.",
        "   `---......_______,,,`.___.'----...x.'         `.;",
        "                                     `-`           `",
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? SharkEntity.sharkShapeRight : SharkEntity.sharkShapeLeft
        let mask = randomDir > 0 ? SharkEntity.sharkMaskRight : SharkEntity.sharkMaskLeft

        super.init(name: name, type: .shark, shape: shape, position: position)
        self.direction = randomDir
        self.colorMask = mask  // Set color mask to control visibility (matching Perl: color => $shark_mask[$dir])
        setupShark()
    }

    private func setupShark() {
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan

        // Set up movement: speed 2, direction-based (matching Perl: callback_args => [ $speed, 0, 0 ])
        // Perl: $speed = 2 (or -2 if left), callback_args => [ $speed, 0, 0 ]
        callbackArgs = [speed, Double(direction), 0.0, 0.0]

    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Shark moves horizontally at speed 2 (matching Perl)
        // Convert speed to grid-based movement: speed * 30 FPS = cells per second
        let gridSpeed = speed * 30.0
        let movementThisFrame = gridSpeed * Double(direction) * deltaTime

        return Position3D(
            position.x + Int(movementThisFrame),
            position.y,
            position.z
        )
    }
}
