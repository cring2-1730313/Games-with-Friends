import Foundation

/// Game mode for Movie Chain
enum MovieChainGameMode: String, CaseIterable, Identifiable {
    case classic
    case timed
    case endless

    var id: String { rawValue }

    var name: String {
        switch self {
        case .classic: return "Classic"
        case .timed: return "Speed Round"
        case .endless: return "Party Mode"
        }
    }

    var description: String {
        switch self {
        case .classic:
            return "Each player has 3 lives. Last one standing wins!"
        case .timed:
            return "Race against the clock. Points for speed!"
        case .endless:
            return "No pressure. See how long you can keep the chain going!"
        }
    }

    var iconName: String {
        switch self {
        case .classic: return "heart.fill"
        case .timed: return "timer"
        case .endless: return "infinity"
        }
    }

    var hasLives: Bool {
        self == .classic
    }

    var hasTimer: Bool {
        self == .timed
    }

    var hasScoring: Bool {
        self == .timed
    }

    var defaultLives: Int { 3 }

    var defaultTimerSeconds: Int { 30 }
}

/// Timer duration options for timed mode
enum TimerDuration: Int, CaseIterable, Identifiable {
    case fifteen = 15
    case twenty = 20
    case thirty = 30
    case fortyFive = 45
    case sixty = 60

    var id: Int { rawValue }

    var label: String {
        "\(rawValue) seconds"
    }
}
