import Foundation

struct VibeCheckSpectrumData {

    /// All available spectrums (polar opposites) for the game
    static let allSpectrums: [VibeCheckSpectrum] = [
        // Social/Cultural
        VibeCheckSpectrum(topLabel: "Trashy", bottomLabel: "Classy"),
        VibeCheckSpectrum(topLabel: "Relaxing", bottomLabel: "Stressful"),
        VibeCheckSpectrum(topLabel: "Divisive", bottomLabel: "Unifying"),
        VibeCheckSpectrum(topLabel: "Overrated", bottomLabel: "Underrated"),
        VibeCheckSpectrum(topLabel: "Boring", bottomLabel: "Exciting"),
        VibeCheckSpectrum(topLabel: "Cringy", bottomLabel: "Cool"),
        VibeCheckSpectrum(topLabel: "Basic", bottomLabel: "Unique"),
        VibeCheckSpectrum(topLabel: "Mainstream", bottomLabel: "Niche"),
        VibeCheckSpectrum(topLabel: "Old-Fashioned", bottomLabel: "Modern"),
        VibeCheckSpectrum(topLabel: "Childish", bottomLabel: "Mature"),

        // Behavior/Personality
        VibeCheckSpectrum(topLabel: "Rude", bottomLabel: "Polite"),
        VibeCheckSpectrum(topLabel: "Lazy", bottomLabel: "Hardworking"),
        VibeCheckSpectrum(topLabel: "Selfish", bottomLabel: "Generous"),
        VibeCheckSpectrum(topLabel: "Introverted", bottomLabel: "Extroverted"),
        VibeCheckSpectrum(topLabel: "Pessimistic", bottomLabel: "Optimistic"),
        VibeCheckSpectrum(topLabel: "Impulsive", bottomLabel: "Calculated"),
        VibeCheckSpectrum(topLabel: "Messy", bottomLabel: "Organized"),
        VibeCheckSpectrum(topLabel: "Cheap", bottomLabel: "Bougie"),
        VibeCheckSpectrum(topLabel: "Awkward", bottomLabel: "Smooth"),
        VibeCheckSpectrum(topLabel: "Annoying", bottomLabel: "Delightful"),

        // Intensity/Energy
        VibeCheckSpectrum(topLabel: "Calm", bottomLabel: "Chaotic"),
        VibeCheckSpectrum(topLabel: "Quiet", bottomLabel: "Loud"),
        VibeCheckSpectrum(topLabel: "Mild", bottomLabel: "Intense"),
        VibeCheckSpectrum(topLabel: "Safe", bottomLabel: "Dangerous"),
        VibeCheckSpectrum(topLabel: "Easy", bottomLabel: "Difficult"),
        VibeCheckSpectrum(topLabel: "Simple", bottomLabel: "Complicated"),
        VibeCheckSpectrum(topLabel: "Slow", bottomLabel: "Fast"),
        VibeCheckSpectrum(topLabel: "Gentle", bottomLabel: "Aggressive"),

        // Quality/Value
        VibeCheckSpectrum(topLabel: "Cheap", bottomLabel: "Expensive"),
        VibeCheckSpectrum(topLabel: "Worthless", bottomLabel: "Valuable"),
        VibeCheckSpectrum(topLabel: "Ugly", bottomLabel: "Beautiful"),
        VibeCheckSpectrum(topLabel: "Disgusting", bottomLabel: "Delicious"),
        VibeCheckSpectrum(topLabel: "Terrible", bottomLabel: "Amazing"),
        VibeCheckSpectrum(topLabel: "Useless", bottomLabel: "Essential"),
        VibeCheckSpectrum(topLabel: "Forgettable", bottomLabel: "Memorable"),
        VibeCheckSpectrum(topLabel: "Fake", bottomLabel: "Authentic"),

        // Time/Relevance
        VibeCheckSpectrum(topLabel: "Outdated", bottomLabel: "Trendy"),
        VibeCheckSpectrum(topLabel: "Temporary", bottomLabel: "Timeless"),
        VibeCheckSpectrum(topLabel: "Past Its Prime", bottomLabel: "In Its Prime"),
        VibeCheckSpectrum(topLabel: "Dying", bottomLabel: "Growing"),

        // Morality/Ethics
        VibeCheckSpectrum(topLabel: "Evil", bottomLabel: "Good"),
        VibeCheckSpectrum(topLabel: "Wrong", bottomLabel: "Right"),
        VibeCheckSpectrum(topLabel: "Problematic", bottomLabel: "Wholesome"),
        VibeCheckSpectrum(topLabel: "Sketchy", bottomLabel: "Trustworthy"),
        VibeCheckSpectrum(topLabel: "Guilty Pleasure", bottomLabel: "Proudly Enjoyed"),

        // Social Perception
        VibeCheckSpectrum(topLabel: "Embarrassing", bottomLabel: "Impressive"),
        VibeCheckSpectrum(topLabel: "Cringe", bottomLabel: "Based"),
        VibeCheckSpectrum(topLabel: "Try-Hard", bottomLabel: "Effortless"),
        VibeCheckSpectrum(topLabel: "Pretentious", bottomLabel: "Down-to-Earth"),
        VibeCheckSpectrum(topLabel: "Normie", bottomLabel: "Elite"),

        // Emotional Impact
        VibeCheckSpectrum(topLabel: "Depressing", bottomLabel: "Uplifting"),
        VibeCheckSpectrum(topLabel: "Scary", bottomLabel: "Comforting"),
        VibeCheckSpectrum(topLabel: "Frustrating", bottomLabel: "Satisfying"),
        VibeCheckSpectrum(topLabel: "Sad", bottomLabel: "Happy"),
        VibeCheckSpectrum(topLabel: "Lonely", bottomLabel: "Social"),

        // Practical
        VibeCheckSpectrum(topLabel: "Impractical", bottomLabel: "Practical"),
        VibeCheckSpectrum(topLabel: "Risky", bottomLabel: "Safe"),
        VibeCheckSpectrum(topLabel: "Unhealthy", bottomLabel: "Healthy"),
        VibeCheckSpectrum(topLabel: "Wasteful", bottomLabel: "Eco-Friendly"),
        VibeCheckSpectrum(topLabel: "High Maintenance", bottomLabel: "Low Maintenance"),

        // Fun/Entertainment
        VibeCheckSpectrum(topLabel: "Lame", bottomLabel: "Fun"),
        VibeCheckSpectrum(topLabel: "Predictable", bottomLabel: "Surprising"),
        VibeCheckSpectrum(topLabel: "Dry", bottomLabel: "Hilarious"),
        VibeCheckSpectrum(topLabel: "Dull", bottomLabel: "Thrilling"),

        // Relationships
        VibeCheckSpectrum(topLabel: "Red Flag", bottomLabel: "Green Flag"),
        VibeCheckSpectrum(topLabel: "Deal Breaker", bottomLabel: "Bonus Points"),
        VibeCheckSpectrum(topLabel: "First Date No", bottomLabel: "First Date Yes"),
        VibeCheckSpectrum(topLabel: "Friend Zone", bottomLabel: "Relationship Material"),

        // Food/Drink
        VibeCheckSpectrum(topLabel: "Gross", bottomLabel: "Tasty"),
        VibeCheckSpectrum(topLabel: "Junk Food", bottomLabel: "Gourmet"),
        VibeCheckSpectrum(topLabel: "Hangover Food", bottomLabel: "Fine Dining"),

        // Lifestyle
        VibeCheckSpectrum(topLabel: "Stay Home", bottomLabel: "Go Out"),
        VibeCheckSpectrum(topLabel: "City Life", bottomLabel: "Country Life"),
        VibeCheckSpectrum(topLabel: "Morning Person", bottomLabel: "Night Owl"),
        VibeCheckSpectrum(topLabel: "Work", bottomLabel: "Play"),
    ]

    /// Get a random spectrum
    static func randomSpectrum() -> VibeCheckSpectrum {
        allSpectrums.randomElement() ?? allSpectrums[0]
    }

    /// Get a random target position (0.0 to 1.0)
    static func randomTargetPosition() -> Double {
        // Avoid extreme edges, keep between 0.05 and 0.95
        Double.random(in: 0.05...0.95)
    }

    /// Get multiple random unique spectrums
    static func randomSpectrums(count: Int) -> [VibeCheckSpectrum] {
        Array(allSpectrums.shuffled().prefix(count))
    }
}
