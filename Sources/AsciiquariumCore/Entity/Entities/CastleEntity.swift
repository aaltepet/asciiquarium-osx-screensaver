//
//  CastleEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Castle Entity
public class CastleEntity: BaseEntity {
    public init(name: String, position: Position3D) {
        let castleShape = [
            "               T~~",
            "               |",
            "              /^\\",
            "             /   \\",
            " _   _   _  /     \\  _   _   _",
            "[ ]_[ ]_[ ]/ _   _ \\[ ]_[ ]_[ ]",
            "|_=__-_ =_|_[ ]_[ ]_|_=-___-__|",
            " | _- =  | =_ = _    |= _=   |",
            " |= -[]  |- = _ =    |_-=_[] |",
            " | =_    |= - ___    | =_ =  |",
            " |=  []- |-  /| |\\   |=_ =[] |",
            " |- =_   | =| | | |  |- = -  |",
            " |_______|__|_|_|_|__|_______|",
        ]
        super.init(name: name, type: .castle, shape: castleShape, position: position)
        setupCastle()
    }

    private func setupCastle() {
        // Use a visible default color for the castle silhouette
        defaultColor = .white
        colorMask = [
            "               xRR             ",
            "               x               ",
            "              yyy              ",
            "             yxxxy             ",
            " x   x   x  yxxxxxy  x   x   x ",
            "xxx xxx xxxyxxxxxxxyxxx xxx xxx",
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            " xxxxxxxxxxxxxxxxxxxxxxxxxxxxx ",
            " xxxxxxxxxxxxxxxxxxxxxxxxxxxxx ",
            " xxxxxxxxxxxxxyyyxxxxxxxxxxxxx ",
            " xxxxxxxxxxxxyyxyyxxxxxxxxxxxx ",
            " xxxxxxxxxxxyxyxyxyxxxxxxxxxxx ",
            " xxxxxxxxxxxyyyyyyyxxxxxxxxxxx ",

        ]
        // Castle is static
    }

    public override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil  // Castle is static
    }
}
