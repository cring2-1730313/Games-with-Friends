import SwiftUI

struct CompetitionScoreboardView: View {
    var viewModel: CompetitionVibeCheckViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerSection

            // Player standings
            standingsSection

            Spacer()

            // Next round info
            nextRoundInfo

            // Continue button
            continueButton
        }
        .padding()
        .background {
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)

            Text("SCOREBOARD")
                .font(.title2.weight(.bold))

            Text("Target: \(viewModel.settings.targetScore) pts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var standingsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.sortedPlayersByScore.enumerated()), id: \.element.id) { index, player in
                CompetitionPlayerScoreRow(
                    rank: index + 1,
                    player: player,
                    targetScore: viewModel.settings.targetScore,
                    isLeading: index == 0
                )
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private var nextRoundInfo: some View {
        VStack(spacing: 8) {
            Text("Round \(viewModel.rounds.count + 1)")
                .font(.headline)
                .foregroundStyle(.orange)

            HStack(spacing: 6) {
                Image(systemName: "shuffle")
                Text("Vibe Setter will be randomly selected")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        }
    }

    private var continueButton: some View {
        Button {
            viewModel.continueToNextRound()
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("NEXT ROUND")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Player Score Row

struct CompetitionPlayerScoreRow: View {
    let rank: Int
    let player: CompetitionPlayer
    let targetScore: Int
    let isLeading: Bool

    private var progress: Double {
        min(1.0, Double(player.score) / Double(targetScore))
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                // Rank indicator
                ZStack {
                    if rank == 1 {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 32, height: 32)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    } else if rank == 2 {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 32, height: 32)

                        Text("2")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    } else if rank == 3 {
                        Circle()
                            .fill(Color.orange.opacity(0.8))
                            .frame(width: 32, height: 32)

                        Text("3")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 32)

                        Text("\(rank)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }

                // Player name
                Text(player.name)
                    .font(.headline)

                Spacer()

                // Score
                Text("\(player.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(isLeading ? .orange : .primary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = CompetitionVibeCheckViewModel()
    viewModel.settings.playerCount = 4
    viewModel.proceedToPlayerSetup()
    viewModel.players[0].name = "Alice"
    viewModel.players[1].name = "Bob"
    viewModel.players[2].name = "Charlie"
    viewModel.players[3].name = "Diana"
    viewModel.players[0].score = 175
    viewModel.players[1].score = 125
    viewModel.players[2].score = 100
    viewModel.players[3].score = 50
    return CompetitionScoreboardView(viewModel: viewModel)
}
