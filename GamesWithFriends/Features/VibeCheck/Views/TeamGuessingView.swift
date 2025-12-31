import SwiftUI

struct TeamGuessingView: View {
    @ObservedObject var viewModel: VibeCheckViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Header
            headerSection

            // The prompt to evaluate
            promptCard

            // Spectrum slider for guessing
            if let round = viewModel.currentRound {
                SpectrumSliderView(
                    spectrum: round.spectrum,
                    position: $viewModel.currentGuessPosition,
                    isInteractive: true
                )
            }

            // Instructions
            instructionsCard

            // Lock in button
            lockInButton
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom)
        .background {
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            if let round = viewModel.currentRound {
                Text("Round \(round.roundNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let team = viewModel.currentGuessingTeam {
                HStack(spacing: 4) {
                    Image(systemName: "hand.tap.fill")
                    Text(team.name)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
            }
        }
    }

    private var promptCard: some View {
        VStack(spacing: 4) {
            if let round = viewModel.currentRound {
                Text("\"\(round.prompt)\"")
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        }
    }

    private var instructionsCard: some View {
        HStack(spacing: 6) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.subheadline)

            Text("Discuss as a team! Slide to where you think the prompt belongs.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        }
    }

    private var lockInButton: some View {
        Button {
            viewModel.submitGuess()
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                Text("LOCK IN GUESS")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let viewModel = VibeCheckViewModel()
    viewModel.settings.teamCount = 2
    viewModel.settings.playersPerTeam = 3
    viewModel.proceedToTeamSetup()
    viewModel.startGame()
    viewModel.confirmPromptSetterReady()
    viewModel.currentPrompt = "Clipping your nails in a movie theater"
    viewModel.submitPrompt()
    viewModel.confirmGuessingTeamReady()
    return TeamGuessingView(viewModel: viewModel)
}
