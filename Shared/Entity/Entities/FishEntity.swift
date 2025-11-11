//
//  FishEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Fish Entity
class FishEntity: BaseEntity {
    var speed: Double = 1.0
    var direction: Int = 1  // 1 for right, -1 for left
    var bubbleChance: Double = 0.03  // 3% chance per frame to generate bubble

    init(name: String, position: Position3D) {
        super.init(name: name, type: .fish, shape: [""], position: position)
        // Set up fish-specific properties
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan

        // Randomize initial direction and appearance
        direction = Bool.random() ? 1 : -1
        setupRandomFishAppearance()

        // Randomize speed matching Perl: rand(2) + .25 (0.25 to 2.25)
        // Ensure speed is never 0 or too close to 0 - minimum 0.25
        speed = max(0.25, Double.random(in: 0.25...2.25))

        // Sync movement args with randomized direction and speed
        // Perl stores: callback_args => [ $speed, 0, 0 ]
        // Swift uses: [speed, dx, dy, dz] where dx is direction
        callbackArgs = [speed, Double(direction), 0.0, 0.0]
    }

    private func setupRandomFishAppearance() {
        // Right-facing shapes with their color masks
        // ColorMask: space = transparent (exterior), non-space = opaque (interior + body)
        let rightFacingShapes: [[String]] = [
            [
                "       \\",
                "     ...\\..,",
                "\\  /'       \\",
                " >=     (  ' >",
                "/  \\      / /",
                "    `\"'\"'/'",
            ],
            [
                "    \\",
                "\\ /--\\",
                ">=  (o>",
                "/ \\__/",
                "    /",
            ],
            [
                "       \\:.       ",
                "\\;,   ,;\\\\\\\\\\,,  ",
                "  \\\\\\\\\\;;:::::::o",
                "  ///;;::::::::< ",
                " /;` ``/////``   ",

            ],
            [
                "  __ ",
                "><_'>",
                "   ' ",
            ],
            [
                "   ..\\,  ",
                ">='   ('>",
                "  '''/'' ",
            ],
            [
                "   \\  ",
                "  / \\ ",
                ">=_('>",
                "  \\_/ ",
                "   /  ",
            ],
            [
                "  ,\\ ",
                ">=('>",
                "  '/ ",
            ],
            [
                "  __ ",
                "\\/ o\\",
                "/\\__/",
            ],

        ]

        let rightFacingMasks: [[String]] = [
            [
                "       x",
                "     xxxxxxx",
                "x  xxxxxxxxxx",
                " xxxxxxxxxxxxx",
                "x  xxxxxxxxxx",
                "    xxxxxxx",
            ],
            [
                "    x",
                "x xxxx",
                "xxxxxxx",
                "x xxxx",
                "    x",
            ],
            [
                "       xxx       ",
                "xxx   xxxxxxxxx  ",
                " xxxxxxxxxxxxxxxx",
                "  xxxxxxxxxxxxxx ",
                " xxx xxxxxxxxx   ",
            ],
            [
                "  xx ",
                "xxxxx",
                "   x ",
            ],
            [
                "   xxxx  ",
                "xxxxxxxxx",
                "  xxxxxx ",
            ],
            [
                "   x  ",
                "  xxx ",
                "xxxxxx",
                "  xxx ",
                "   x  ",
            ],
            [
                "  xx ",
                "xxxxx",
                "  xx ",
            ],
            [
                "  xx ",
                "xxxxx",
                "xxxxx",
            ],
        ]

        // Left-facing shapes with their color masks
        let leftFacingShapes: [[String]] = [
            [
                "      /",
                "  ,../...",
                " /       '\\  /",
                "< '  )     =<",
                " \\ \\      /  \\",
                "  `'\\'\"'\"'",
            ],
            [
                "  /",
                " /--\\ /",
                "<o)  =<",
                " \\__/ \\",
                "  \\",
            ],
            [
                "      .:/          ",
                "   ,,///;,   ,;/   ",
                " o:::::::;;///     ",
                ">::::::::;;\\\\\\\\\\   ",
                "  ''\\\\\\\\\\\\\\\\\\'' ';\\",
            ],
            [
                " __  ",
                "<'_><",
                " `   ",
            ],
            [
                "  ,/..   ",
                "<')   `=<",
                " ``\\```  ",
            ],
            [
                "  /   ",
                " / \\  ",
                "<')_=<",
                " \\_/  ",
                "  \\   ",
            ],
            [
                " /,  ",
                "<')=<",
                " \\`  ",
            ],
            [
                " __  ",
                "/o \\/",
                "\\__/\\",
            ],
        ]

        let leftFacingMasks: [[String]] = [
            [
                "      x",
                "  xxxxxxx",
                " xxxxxxxxxx  x",
                "xxxxxxxxxxxxx",
                " xxxxxxxxxx  x",
                "  xxxxxxxx",

            ],
            [
                "  x",
                " xxxx x",
                "xxxxxxx",
                " xxxx x",
                "  x",
            ],
            [
                "      xxx          ",
                "   xxxxxxx   xxx   ",
                " xxxxxxxxxxxxx     ",
                "xxxxxxxxxxxxxxxx   ",
                "  xxxxxxxxxxxxx xxx",
            ],
            [
                " xx  ",
                "xxxxx",
                " x   ",
            ],
            [
                "  xxxx   ",
                "xxxxxxxxx",
                " xxxxxx  ",
            ],
            [
                "  x   ",
                " xxx  ",
                "xxxxxx",
                " xxx  ",
                "  x   ",
            ],
            [
                " xx  ",
                "xxxxx",
                " xx  ",
            ],
            [
                " xx  ",
                "xxxxx",
                "xxxxx",
            ],
        ]

        // Pick from the set matching our direction
        let shapeIndex: Int
        if direction > 0 {
            shapeIndex = Int.random(in: 0..<rightFacingShapes.count)
            shape = rightFacingShapes[shapeIndex]
            colorMask = rightFacingMasks[shapeIndex]
        } else {
            shapeIndex = Int.random(in: 0..<leftFacingShapes.count)
            shape = leftFacingShapes[shapeIndex]
            colorMask = leftFacingMasks[shapeIndex]
        }

        // Random color
        let colors: [ColorCode] = [.cyan, .red, .yellow, .blue, .green, .magenta]
        defaultColor = colors.randomElement() ?? .cyan
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Fish-specific movement logic - speed is randomized (0.25 to 2.25) matching Perl
        // Convert speed to grid-based movement: speed * 30 FPS = cells per second
        let gridSpeed = speed * 30.0
        let moveX = Int(gridSpeed * Double(direction) * deltaTime)

        return Position3D(
            position.x + moveX,
            position.y,
            position.z
        )
    }

    func shouldGenerateBubble() -> Bool {
        return Double.random(in: 0...1) < bubbleChance
    }

    func generateBubblePosition() -> Position3D {
        // Bubble appears above the fish
        let bubbleX = direction > 0 ? position.x + size.width : position.x
        let bubbleY = position.y + size.height / 2
        return Position3D(bubbleX, bubbleY, position.z - 1)
    }
}
