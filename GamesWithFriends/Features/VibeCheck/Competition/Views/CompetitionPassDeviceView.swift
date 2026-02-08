import SwiftUI

struct CompetitionPassDeviceView: View {
    let playerName: String
    let role: PlayerRole
    let onReady: () -> Void

    enum PlayerRole {
        case vibeSetter
        case guesser

        var title: String {
            switch self {
            case .vibeSetter: return "Vibe Setter"
            case .guesser: return "Guesser"
            }
        }

        var icon: String {
            switch self {
            case .vibeSetter: return "person.fill.questionmark"
            case .guesser: return "hand.tap.fill"
            }
        }

        var instruction: String {
            switch self {
            case .vibeSetter: return "You'll see a target position and create a prompt that matches it"
            case .guesser: return "You'll see the prompt and guess where it belongs on the spectrum"
            }
        }

        var color: Color {
            switch self {
            case .vibeSetter: return .purple
            case .guesser: return .orange
            }
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Device passing icon
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, options: .repeating)

            // Pass instruction
            VStack(spacing: 16) {
                Text("Pass the device to")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(playerName)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(role.color)

                // Role badge
                HStack(spacing: 8) {
                    Image(systemName: role.icon)
                    Text(role.title)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(role.color)
                }
            }

            // Instructions
            Text(role.instruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Ready button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onReady()
            } label: {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("I'M READY")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    LinearGradient(
                        colors: [role.color, role.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            // Privacy reminder
            if role == .guesser {
                Text("Don't look at other players' guesses!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Keep the target position secret!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            LinearGradient(
                colors: [role.color.opacity(0.1), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Wrapper for ViewModel Integration

struct CompetitionVibeSetterPassView: View {
    var viewModel: CompetitionVibeCheckViewModel

    var body: some View {
        if let setter = viewModel.vibeSetter {
            CompetitionPassDeviceView(
                playerName: setter.name,
                role: .vibeSetter
            ) {
                viewModel.confirmVibeSetterReady()
            }
        }
    }
}

struct CompetitionGuesserPassView: View {
    var viewModel: CompetitionVibeCheckViewModel

    var body: some View {
        if let player = viewModel.currentGuessingPlayer {
            CompetitionPassDeviceView(
                playerName: player.name,
                role: .guesser
            ) {
                viewModel.confirmGuessingPlayerReady()
            }
        }
    }
}

#Preview("Vibe Setter") {
    CompetitionPassDeviceView(
        playerName: "Alice",
        role: .vibeSetter
    ) {}
}

#Preview("Guesser") {
    CompetitionPassDeviceView(
        playerName: "Bob",
        role: .guesser
    ) {}
}
