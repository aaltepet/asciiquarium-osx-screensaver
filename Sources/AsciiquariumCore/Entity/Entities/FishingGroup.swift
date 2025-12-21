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

    /// The source of truth for the vertical position of the assembly.
    /// This is updated by the 'leader' (the hook) and followed by others.
    public var y: Double = 0.0

    public weak var hook: Entity?
    public weak var line: Entity?
    public weak var point: Entity?

    public init() {}

    public func retract() {
        state = .retracting
    }

    public func killAll() {
        hook?.kill()
        line?.kill()
        point?.kill()
        caughtFish?.kill()
    }
}
