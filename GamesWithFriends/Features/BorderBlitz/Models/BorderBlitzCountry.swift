//
//  Country.swift
//  BorderBlitz
//

import Foundation
import CoreGraphics

struct BorderBlitzCountry: Identifiable, Codable {
    let id: String
    let name: String
    let borderPoints: [CGPoint]

    /// Alternate names that should be accepted as correct answers
    var alternateNames: [String] = []

    /// Normalized name for comparison (lowercase, no special chars)
    var normalizedName: String {
        name.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }

    /// Get all acceptable answers (main name + alternates)
    var acceptableAnswers: [String] {
        ([name] + alternateNames).map { answer in
            answer.lowercased()
                .folding(options: .diacriticInsensitive, locale: .current)
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .joined()
        }
    }

    /// Check if a guess matches this country
    func isMatch(_ guess: String) -> Bool {
        let normalizedGuess = guess.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()

        return acceptableAnswers.contains(normalizedGuess)
    }
}
