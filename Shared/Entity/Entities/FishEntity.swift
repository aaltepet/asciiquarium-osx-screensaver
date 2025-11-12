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
    var bubbleChance: Double = 0.005  // 0.5% chance per frame to generate bubble (adjusted from 3% due to frame rate differences)
    private var accumulatedMovement: Double = 0.0  // Accumulate fractional movement to preserve speed differences

    init(name: String, position: Position3D) {
        super.init(name: name, type: .fish, shape: [""], position: position)
        // Set up fish-specific properties
        isPhysical = true
        dieOffscreen = true
        defaultColor = .cyan

        // Randomize initial direction and appearance
        direction = Bool.random() ? 1 : -1
        setupRandomFishAppearance()

        // Randomize speed matching Perl: rand(2) + .05 (0.05 to 0.9)
        // Ensure speed is never 0 or too close to 0 - minimum 0.05
        speed = Double.random(in: 0.05...0.9)
        // Explicit safeguard: ensure speed is always at least 0.05 (defensive programming)
        speed = max(0.05, speed)

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

        // Numbered color masks matching Perl (1=body, 2=dorsal fin, 3=flippers, 4=eye, 5=mouth, 6=tailfin, 7=gills)
        let rightFacingMasks: [[String]] = [
            [
                "       2      ",
                "     1112111  ",
                "6  11xxxxxxx1 ",
                " 66xxxxx7xx4x5",
                "6  1xxxxxx3x1 ",
                "    11111311  ",
            ],
            [
                "    2  ",
                "6 1111 ",
                "66xx745",
                "6 1111 ",
                "    3  ",
            ],
            [
                "       222       ",
                "666   1122211    ",
                "  6661111111114  ",
                "  66611111111115 ",
                " 666 113333311   ",
            ],
            [
                "  11 ",
                "61145",
                "   3 ",
            ],
            [
                "   1121  ",
                "661xxx745",
                "  111311 ",
            ],
            [
                "   2  ",
                "  1x1 ",
                "661745",
                "  111 ",
                "   3  ",
            ],
            [
                "  12 ",
                "66745",
                "  13 ",
            ],
            [
                "  11 ",
                "61x41",
                "61111",
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
                "  ''\\\\\\\\\\\\'' ';\\",
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

        // Numbered color masks matching Perl (1=body, 2=dorsal fin, 3=flippers, 4=eye, 5=mouth, 6=tailfin, 7=gills)
        let leftFacingMasks: [[String]] = [
            [
                "      2       ",
                "  1112111     ",
                " 1xxxxxxx11  6",
                "5x4x7xxxxxx66 ",
                " 1x3xxxxxx1  6",
                "  11311111    ",
            ],
            [
                "  2    ",
                " 1111 6",
                "547xx66",
                " 1111 6",
                "  3    ",
            ],
            [
                "      222       ",
                "   1122211   666",
                " 4111111111666  ",
                "51111111111666  ",
                "  113333311 666 ",
            ],
            [
                " 11  ",
                "54116",
                " 3   ",
            ],
            [
                "  1211",
                "547xxx166",
                " 113111",
            ],
            [
                "  2   ",
                " 1x1  ",
                "547166",
                " 111  ",
                "  3   ",
            ],
            [
                " 21  ",
                "54766",
                " 31  ",
            ],
            [
                " 11  ",
                "14x16",
                "11116",
            ],
        ]

        // Pick from the set matching our direction
        let shapeIndex: Int
        var selectedMask: [String]
        if direction > 0 {
            shapeIndex = Int.random(in: 0..<rightFacingShapes.count)
            shape = rightFacingShapes[shapeIndex]
            selectedMask = rightFacingMasks[shapeIndex]
        } else {
            shapeIndex = Int.random(in: 0..<leftFacingShapes.count)
            shape = leftFacingShapes[shapeIndex]
            selectedMask = leftFacingMasks[shapeIndex]
        }

        // Replace eye (4) with white (W) before randomization, matching Perl line 496
        selectedMask = selectedMask.map { line in
            line.replacingOccurrences(of: "4", with: "W")
        }

        // Randomize colors matching Perl's rand_color() function
        colorMask = randomizeFishColors(colorMask: selectedMask)

        // Default color is no longer used for fish (using per-character colors), but keep for compatibility
        defaultColor = .cyan
    }

    /// Randomize fish colors matching Perl's rand_color() function
    /// Replaces numbers 1-9 in color mask with random colors from the palette
    /// - Parameter colorMask: Color mask with numbers 1-9 representing body parts
    /// - Returns: Color mask with numbers replaced by random color codes
    /// - Note: Eye (4) should be replaced with 'W' (white) before calling this function
    private func randomizeFishColors(colorMask: [String]) -> [String] {
        // Perl colors: ('c','C','r','R','y','Y','b','B','g','G','m','M')
        let colors: [ColorCode] = [
            .cyan, .cyanBright, .red, .redBright, .yellow, .yellowBright,
            .blue, .blueBright, .green, .greenBright, .magenta, .magentaBright,
        ]

        return colorMask.map { line in
            var result = line
            // Replace each number (1-9) with a random color, matching Perl's behavior
            // Perl: foreach my $i (1..9) { $color_mask =~ s/$i/$color/gm; }
            for num in 1...9 {
                let numStr = String(num)
                let randomColor = colors.randomElement() ?? .cyan
                result = result.replacingOccurrences(of: numStr, with: String(randomColor.rawValue))
            }
            return result
        }
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Fish-specific movement logic - speed is randomized (0.05 to 2.0) matching Perl
        // Ensure speed is valid (safeguard against any edge cases)
        if speed < 0.05 {
            // If speed somehow became invalid, reset to minimum
            speed = 0.05
        }

        // Convert speed to grid-based movement: speed * 30 FPS = cells per second
        let gridSpeed = speed * 30.0
        let movementThisFrame = gridSpeed * Double(direction) * deltaTime

        // Accumulate fractional movement to preserve speed differences
        // This ensures slow fish move slower than fast fish, even with integer positions
        accumulatedMovement += movementThisFrame
        let moveX = Int(accumulatedMovement)
        accumulatedMovement -= Double(moveX)  // Keep the fractional part for next frame

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
        // Perl: bubble_pos[0] += fish_size[0] if moving right
        //       bubble_pos[1] += int(fish_size[1] / 2)
        //       bubble_pos[2]-- (bubble always goes on top of the fish)
        let bubbleX = direction > 0 ? position.x + size.width : position.x
        let bubbleY = position.y + size.height / 2
        return Position3D(bubbleX, bubbleY, position.z - 1)
    }

    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)

        // Check if fish should generate a bubble
        // Perl: if(int(rand(100)) > 97) { add_bubble($fish, $anim); } - 3% chance per frame
        // However the movement timing in this implementation is different (Swift runs at 30 FPS vs Perl's lower frame rate),
        // so we use 0.5% chance per frame to achieve similar visual bubble frequency as the Perl version.
        if shouldGenerateBubble() {
            let bubblePos = generateBubblePosition()
            let bubble = EntityFactory.createBubble(at: bubblePos)
            // Use spawn callback to add bubble to engine
            spawnCallback?(bubble)
        }
    }
}
