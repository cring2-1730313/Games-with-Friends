import SwiftUI

/// Final results screen after all rounds are complete
struct CastingDirectorGameOverView: View {
    @ObservedObject var viewModel: CastingDirectorViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Trophy header
                    trophyHeader

                    // Standings or solo score
                    if viewModel.gameMode == .passAndPlay {
                        standingsSection
                    } else {
                        soloScoreSection
                    }

                    // Stats
                    statsSection

                    // Actions
                    actionButtons
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Trophy Header

    private var trophyHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(.yellow)

            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)

            if viewModel.gameMode == .passAndPlay, let winner = viewModel.winner {
                HStack(spacing: 6) {
                    Circle()
                        .fill(winner.color)
                        .frame(width: 14, height: 14)
                    Text("\(winner.name) wins!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Standings

    private var standingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Final Standings")
                .font(.headline)

            ForEach(Array(viewModel.standings.enumerated()), id: \.element.id) { index, player in
                HStack(spacing: 12) {
                    // Rank
                    Text("#\(index + 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(index == 0 ? .yellow : .secondary)
                        .frame(width: 40)

                    Circle()
                        .fill(player.color)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.headline)
                        Text("\(player.correctGuesses) correct, \(player.wrongGuesses) wrong")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(player.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.indigo)
                }
                .padding()
                .background(index == 0 ? Color.yellow.opacity(0.1) : Color.clear)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Solo Score

    private var soloScoreSection: some View {
        VStack(spacing: 16) {
            let player = viewModel.players.first ?? CastingDirectorPlayer(name: "Player")

            VStack(spacing: 4) {
                Text("Total Score")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("\(player.score)")
                    .font(.system(size: 48))
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.indigo)
            }

            HStack(spacing: 24) {
                StatBubble(label: "Correct", value: "\(player.correctGuesses)", icon: "checkmark.circle.fill", color: .green)
                StatBubble(label: "Wrong", value: "\(player.wrongGuesses)", icon: "xmark.circle.fill", color: .red)
                StatBubble(label: "Streak", value: "\(viewModel.bestStreak)", icon: "flame.fill", color: .orange)
            }

            // High score comparison
            if player.score >= viewModel.highScore && player.score > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("New High Score!")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                .padding(.top, 4)
            } else if viewModel.highScore > 0 {
                Text("High Score: \(viewModel.highScore)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Stats")
                .font(.headline)

            HStack(spacing: 12) {
                CastingDirectorStatCard(label: "Rounds", value: "\(viewModel.numberOfRounds)", icon: "number.circle.fill")
                CastingDirectorStatCard(label: "Difficulty", value: viewModel.difficulty.rawValue, icon: "slider.horizontal.3")
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.playAgain()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Play Again")
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
}

// MARK: - Stat Bubble

struct StatBubble: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Stat Card

struct CastingDirectorStatCard: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.indigo)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
