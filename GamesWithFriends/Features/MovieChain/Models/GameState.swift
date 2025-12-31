import Foundation

/// The current phase of the Movie Chain game
enum MovieChainPhase: Equatable {
    case setup
    case playing
    case chainBroken(reason: ChainBreakReason)
    case gameOver(winner: MovieChainPlayer?)
}

/// Reason why the chain was broken
enum ChainBreakReason: Equatable {
    case invalidAnswer(submitted: String, expected: String) // e.g., actor not in movie
    case alreadyUsed(name: String) // movie or actor already in chain
    case timerExpired
    case playerGaveUp

    var message: String {
        switch self {
        case .invalidAnswer(let submitted, let expected):
            return "\"\(submitted)\" is not valid for \(expected)"
        case .alreadyUsed(let name):
            return "\"\(name)\" was already used in this chain"
        case .timerExpired:
            return "Time ran out!"
        case .playerGaveUp:
            return "Player gave up"
        }
    }
}

/// What type of answer is expected for the current turn
enum TurnType: Equatable {
    case movie  // Player must name a movie the current actor was in
    case actor  // Player must name an actor from the current movie

    var prompt: String {
        switch self {
        case .movie:
            return "Name a movie with"
        case .actor:
            return "Name an actor from"
        }
    }

    var searchPlaceholder: String {
        switch self {
        case .movie:
            return "Search for a movie..."
        case .actor:
            return "Search for an actor..."
        }
    }

    var opposite: TurnType {
        switch self {
        case .movie: return .actor
        case .actor: return .movie
        }
    }
}
