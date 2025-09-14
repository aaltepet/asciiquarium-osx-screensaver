//
//  CastleEntity.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 9/10/25.
//

import Foundation

// MARK: - Castle Entity
class CastleEntity: BaseEntity {
    init(name: String, position: Position3D) {
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
        defaultColor = .black
        // Castle is static
    }

    override func moveEntity(deltaTime: TimeInterval) -> Position3D? {
        return nil  // Castle is static
    }
}
