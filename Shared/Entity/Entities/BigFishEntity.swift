//
//  BigFishEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 11/18/25.
//

import Foundation

// MARK: - Big Fish Entity
class BigFishEntity: BaseEntity {
    var direction: Int = 1  // 1 for right, -1 for left
    var speed: Double = 1  // Speed matching Perl: $speed = 3
    private var fractionalX: Double = 0.0  // Accumulate fractional movement

    // Big fish shapes (left and right facing) - matching Perl
    private static let bigFishShapeRight = [
        " ______",
        "`\"\"-.  `````-----.....__",
        "     `.  .      .       `-.",
        "       :     .     .       `.",
        " ,     :   .    .          _ :",
        ": `.   :                  (@) `._",
        " `. `..'     .     =`-.       .__)",
        "   ;     .        =  ~  :     .-\"",
        " .' .'`.   .    .  =.-'  `._ .'",
        ": .'   :               .   .'",
        " '   .'  .    .     .   .-'",
        "   .'____....----''.'=.'",
        "   \"\"             .'.'",
        "               ''\"'`",
    ]

    private static let bigFishShapeLeft = [
        "                           ______",
        "          __.....-----'''''  .-\"\"'",
        "       .-'       .      .  .'",
        "     .'       .     .     :",
        "    : _          .    .   :     ,",
        " _.' (@)                  :   .' :",
        "(__.       .-'=     .     `..' .'",
        " \"-.     :  ~  =        .     ;",
        "   `. _.'  `-.=  .    .   .'`. `.",
        "     `.   .               :   `. :",
        "       `-.   .     .    .  `.   `",
        "          `.=`.``----....____`.",
        "            `.`.             \"\"",
        "              '`\"``",
    ]

    // Big fish color masks (matching Perl: @big_fish_mask)
    // Spaces in mask = transparent, color codes = visible
    // '1' = yellow (body), '2' = yellow bright (fins/details), 'W' = white (eye)
    // Note: Perl uses rand_color() to randomize colors, but we'll use fixed colors for now
    private static let bigFishMaskRight = [
        " 111111",
        "11111xx11111111111111111",
        "     11xx2xxxxxx2xxxxxxx111",
        "       1xxxxx2xxxxx2xxxxxxx11",
        " 1     1xxx2xxxx2xxxxxxxxxx1x1",
        "1x11   1xxxxxxxxxxxxxxxxx1W1x111",
        " 11x1111xxxxx2xxxxx1111xxxxxxx1111",
        "   1xxxxx2xxxxxxxx1xx1xx1xxxxx111",
        " 11x1111xxx2xxxx2xx1111xx111x11",
        "1x11xxx1xxxxxxxxxxxxxxx2xxx11",
        " 1xxx11xx2xxxx2xxxxx2xxx111",
        "   111111111111111111111",
        "   11             1111",
        "               11111",
    ]

    private static let bigFishMaskLeft = [
        "                           111111",
        "          11111111111111111xx11111",
        "       111xxxxxxx2xxxxxx2xx11",
        "     11xxxxxxx2xxxxx2xxxxx1",
        "    1x1xxxxxxxxxx2xxxx2xxx1xxxxx1",
        " 111x1W1xxxxxxxxxxxxxxxxxx1xxx11x1",
        "1111xxxxxxx1111xxxxx2xxxxx1111x11",
        " 111xxxxx1xx1xx1xxxxxxxx2xxxxx1",
        "   11x111xx1111xx2xxxx2xxx1111x11",
        "     11xxx2xxxxxxxxxxxxxxx1xxx11x1",
        "       111xxx2xxxxx2xxxx2xx11xxx1",
        "          111111111111111111111",
        "            1111             11",
        "              11111",
    ]

    init(name: String, position: Position3D) {
        // Randomize direction (0 = left, 1 = right)
        let randomDir = Bool.random() ? 1 : -1
        let shape = randomDir > 0 ? BigFishEntity.bigFishShapeRight : BigFishEntity.bigFishShapeLeft
        let mask = randomDir > 0 ? BigFishEntity.bigFishMaskRight : BigFishEntity.bigFishMaskLeft

        super.init(name: name, type: .bigFish, shape: shape, position: position)
        direction = randomDir
        colorMask = mask
        dieOffscreen = true
        defaultColor = .yellow
        autoTransparent = true
        // Perl: callback_args => [ $speed, 0, 0 ]
        callbackArgs = [speed, Double(direction), 0.0, 0.0]
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        // Big fish moves horizontally based on direction and speed
        // Use fractional accumulation to handle sub-pixel movement
        let gridSpeed = speed * 30.0  // 30 FPS
        fractionalX += gridSpeed * Double(direction) * deltaTime

        // Extract integer movement and keep remainder
        let moveX = Int(fractionalX)
        fractionalX -= Double(moveX)

        return Position3D(
            position.x + moveX,
            position.y,
            position.z
        )
    }
}
