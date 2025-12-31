import SwiftUI

struct RevealView: View {
    @ObservedObject var viewModel: VibeCheckViewModel
    @State private var showResults = false
    @State private var revealedPositions = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerSection

            ScrollView {
                VStack(spacing: 24) {
                    // The prompt
                    promptCard

                    // Spectrum with both positions revealed
                    if let round = viewModel.currentRound {
                        revealSection(round: round)
                    }

                    // Results for each team
                    if showResults {
                        resultsSection
                    }
                }
            }

            // Continue button
            continueButton
        }
        .padding()
        .background {
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .onAppear {
            // Animate the reveal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    revealedPositions = true
                }
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showResults = true
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 4) {
            if let round = viewModel.currentRound {
                Text("Round \(round.roundNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("RESULTS")
                .font(.headline)
                .foregroundStyle(.purple)
        }
    }

    private var promptCard: some View {
        VStack(spacing: 8) {
            Text("THE PROMPT")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(2)

            if let round = viewModel.currentRound {
                Text("\"\(round.prompt)\"")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
            }

            if let setter = viewModel.promptSetterTeam {
                Text("Set by \(setter.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    @ViewBuilder
    private func revealSection(round: VibeCheckRound) -> some View {
        let results = viewModel.getRoundResults()

        // For single team or first result, show the main reveal slider
        if let firstResult = results.first {
            VStack(spacing: 16) {
                RevealSliderView(
                    spectrum: round.spectrum,
                    targetPosition: round.targetPosition,
                    guessPosition: firstResult.guessedPosition,
                    zone: firstResult.zone
                )
                .opacity(revealedPositions ? 1 : 0)
                .scaleEffect(revealedPositions ? 1 : 0.9)

                // Legend
                HStack(spacing: 24) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Target")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        Text("Your Guess")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var resultsSection: some View {
        VStack(spacing: 16) {
            Text("SCORING")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(2)

            ForEach(viewModel.getRoundResults()) { result in
                TeamResultRow(result: result)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private var continueButton: some View {
        Button {
            viewModel.proceedFromReveal()
        } label: {
            HStack {
                Image(systemName: viewModel.isGameOver ? "trophy.fill" : "arrow.right.circle.fill")
                Text(viewModel.isGameOver ? "SEE FINAL RESULTS" : "CONTINUE")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .opacity(showResults ? 1 : 0.5)
        .disabled(!showResults)
    }
}

// MARK: - Team Result Row

struct TeamResultRow: View {
    let result: VibeCheckRoundResult

    var body: some View {
        HStack(spacing: 16) {
            // Team name
            VStack(alignment: .leading, spacing: 2) {
                Text(result.teamName)
                    .font(.headline)

                Text(distanceText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Points badge
            HStack(spacing: 6) {
                Circle()
                    .fill(result.zone.color)
                    .frame(width: 16, height: 16)

                Text("+\(result.pointsEarned)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(result.zone.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(result.zone.color.opacity(0.15))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }

    private var distanceText: String {
        let distance = abs(result.guessedPosition - result.targetPosition)
        let percentage = Int(distance * 100)
        return "\(percentage)% away"
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
    viewModel.currentGuessPosition = 0.18
    viewModel.submitGuess()
    return RevealView(viewModel: viewModel)
}
