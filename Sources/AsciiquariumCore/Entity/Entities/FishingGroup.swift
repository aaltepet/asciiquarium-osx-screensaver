//
//  FishingGroup.swift
//  Asciiquarium
//
//  Created by Andy Altepeter on 12/19/25.
//

import Foundation

/// Shared state for a group of fishing entities (hook, line, point)
public class FishingGroup {
    public enum State {
        case descending
        case retracting
    }

    public var state: State = .descending
    public var caughtFish: Entity? = nil

    public init() {}

    public func retract() {
        state = .retracting
    }
}
