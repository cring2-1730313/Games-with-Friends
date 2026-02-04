import Foundation
import SwiftUI

// MARK: - Game Configuration

struct CompetitionVibeCheckSettings: Codable, Equatable {
    var playerCount: Int = 2
    var targetScore: Int = 500

    static let defaultSettings = CompetitionVibeCheckSettings()
}

// MARK: - Player

struct CompetitionPlayer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var score: Int = 0

    init(id: UUID = UUID(), name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
}

// MARK: - Round

struct CompetitionRound: Identifiable, Codable, Equatable {
    let id: UUID
    let roundNumber: Int
    let spectrum: VibeCheckSpectrum
    let targetPosition: Double  // 0.0 = top, 1.0 = bottom
    let vibeSetterId: UUID
    var prompt: String = ""
    var guesses: [CompetitionGuess] = []
    var isComplete: Bool = false

    init(id: UUID = UUID(), roundNumber: Int, spectrum: VibeCheckSpectrum, targetPosition: Double, vibeSetterId: UUID) {
        self.id = id
        self.roundNumber = roundNumber
        self.spectrum = spectrum
        self.targetPosition = targetPosition
        self.vibeSetterId = vibeSetterId
    }
}

// MARK: - Guess

struct CompetitionGuess: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let guessedPosition: Double
    var pointsEarned: Int = 0

    init(id: UUID = UUID(), playerId: UUID, guessedPosition: Double, pointsEarned: Int = 0) {
        self.id = id
        self.playerId = playerId
        self.guessedPosition = guessedPosition
        self.pointsEarned = pointsEarned
    }

    var distance: Double {
        // Note: This needs the target position to calculate distance
        // Distance is calculated at scoring time
        0
    }
}

// MARK: - Game State

enum CompetitionGameState: Equatable {
    case setup
    case playerSetup
    case passingToVibeSetter
    case promptEntry
    case passingToGuesser(playerIndex: Int)
    case guessing(playerIndex: Int)
    case reveal
    case scoreboard
    case gameOver
}

// MARK: - Round Result (for display)

struct CompetitionRoundResult: Identifiable, Equatable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let guessedPosition: Double
    let targetPosition: Double
    let pointsEarned: Int
    let zone: ScoringZone
    let rank: Int

    var distance: Double {
        abs(guessedPosition - targetPosition)
    }

    var distancePercentage: Int {
        Int(distance * 100)
    }
}

// MARK: - Worst Guesser Teases

struct WorstGuesserTease {
    static let messages: [String] = [
        "Oof, someone needs a vibe calibration!",
        "Were you even in the same room?",
        "That's... definitely a unique perspective!",
        "Points for confidence, at least!",
        "Maybe try closing your eyes next time?",
        "The vibes were NOT with you this round.",
        "Hey, at least you're consistent... consistently off!",
        "Did you hold the phone upside down?",
        "Bold move, Cotton. Let's see if it pays off... (it didn't)",
        "You zigged when you should have zagged!",
        "Better luck next time, champ!",
        "Someone's been reading the wrong vibes!",
    ]

    static func randomMessage() -> String {
        messages.randomElement() ?? messages[0]
    }
}
