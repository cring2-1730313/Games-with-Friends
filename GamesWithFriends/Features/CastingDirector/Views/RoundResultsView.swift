import SwiftUI

/// Score display after each round
struct RoundResultsView: View {
    @ObservedObject var viewModel: CastingDirectorViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.2), Color.purple.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Result header
                    resultHeader

                    // Actor reveal
                    actorReveal

                    // Score breakdown
                    scoreBreakdown

                    // Clue summary
                    clueSummary

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Result Header

    private var resultHeader: some View {
        VStack(spacing: 12) {
            if viewModel.roundState.foundByPlayer != nil {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Correct!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)

                Text("Time's Up!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            if viewModel.gameMode == .passAndPlay, let player = viewModel.roundState.foundByPlayer {
                HStack(spacing: 6) {
                    Circle()
                        .fill(player.color)
                        .frame(width: 12, height: 12)
                    Text("\(player.name) got it!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Actor Reveal

    private var actorReveal: some View {
        VStack(spacing: 8) {
            if let actor = viewModel.roundState.targetActor {
                Text("The actor was...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(actor.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.indigo)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Score Breakdown

    private var scoreBreakdown: some View {
        VStack(spacing: 12) {
            Text("Score")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ScoreRow(label: "Base Score", value: "1,000")
                    ScoreRow(label: "Clues Revealed (\(viewModel.roundState.cluesRevealed))", value: "-\(viewModel.roundState.cluesRevealed * 50)", isNegative: true)
                    if viewModel.roundState.wrongGuessCount > 0 {
                        ScoreRow(label: "Wrong Guesses (\(viewModel.roundState.wrongGuessCount))", value: "-\(viewModel.roundState.wrongGuessCount * viewModel.difficulty.wrongGuessPenalty)", isNegative: true)
                    }

                    Divider()

                    HStack {
                        Text("Round Score")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(viewModel.roundState.currentScore)")
                            .fontWeight(.bold)
                            .foregroundStyle(.indigo)
                    }
                    .font(.title3)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Clue Summary

    private var clueSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Clues")
                .font(.headline)

            VStack(spacing: 6) {
                ForEach(viewModel.roundState.revealedClues) { clue in
                    HStack(spacing: 8) {
                        Text("\(clue.orderNumber)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(tierColor(clue.tier))
                            .clipShape(Circle())

                        Image(systemName: clue.type.icon)
                            .font(.caption)
                            .foregroundStyle(tierColor(clue.tier))
                            .frame(width: 16)

                        Text(clue.text)
                            .font(.subheadline)
                            .lineLimit(2)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.nextRound()
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text(viewModel.currentRound >= viewModel.numberOfRounds ? "See Final Results" : "Next Round")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                viewModel.returnToSetup()
            } label: {
                Text("Back to Setup")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top)
    }

    private func tierColor(_ tier: ClueTier) -> Color {
        switch tier {
        case .vague: return .blue
        case .narrowing: return .green
        case .strongSignal: return .orange
        case .giveaway: return .red
        }
    }
}

// MARK: - Score Row

struct ScoreRow: View {
    let label: String
    let value: String
    var isNegative: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(isNegative ? .red : .primary)
        }
    }
}
