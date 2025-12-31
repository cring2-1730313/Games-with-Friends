import SwiftUI

/// View shown when the Movie Chain game ends
struct MovieChainGameOverView: View {
    @ObservedObject var viewModel: MovieChainViewModel
    let winner: MovieChainPlayer?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.red.opacity(0.3), Color.orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Trophy/Winner section
                    winnerSection

                    // Final standings
                    standingsSection

                    // Game stats
                    gameStatsSection

                    // Action buttons
                    actionButtons
                }
                .padding()
            }
        }
    }

    // MARK: - Winner Section

    private var winnerSection: some View {
        VStack(spacing: 16) {
            // Trophy icon
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 120, height: 120)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
            }

            if let winner = winner {
                VStack(spacing: 8) {
                    Text("Winner!")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Circle()
                            .fill(winner.color)
                            .frame(width: 24, height: 24)

                        Text(winner.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }
            } else {
                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding(.top)
    }

    // MARK: - Standings Section

    private var standingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Final Standings")
                .font(.headline)

            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                PlayerStandingRow(
                    rank: index + 1,
                    player: player,
                    gameMode: viewModel.gameMode,
                    isWinner: player.id == winner?.id
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var sortedPlayers: [MovieChainPlayer] {
        switch viewModel.gameMode {
        case .classic:
            // Sort by lives remaining (higher is better), then by links contributed
            return viewModel.players.sorted {
                if $0.lives != $1.lives {
                    return $0.lives > $1.lives
                }
                return $0.linksContributed > $1.linksContributed
            }
        case .timed:
            // Sort by score
            return viewModel.players.sorted { $0.score > $1.score }
        case .endless:
            // Sort by links contributed
            return viewModel.players.sorted { $0.linksContributed > $1.linksContributed }
        }
    }

    // MARK: - Game Stats Section

    private var gameStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Statistics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                GameStatCard(
                    icon: "link",
                    title: "Longest Chain",
                    value: "\(viewModel.longestChainThisGame)"
                )

                GameStatCard(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Total Chains",
                    value: "\(viewModel.totalChainsCompleted)"
                )

                GameStatCard(
                    icon: "film",
                    title: "Movies Named",
                    value: "\(countMovies)"
                )

                GameStatCard(
                    icon: "person.2",
                    title: "Actors Named",
                    value: "\(countActors)"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var countMovies: Int {
        viewModel.players.reduce(0) { total, player in
            // Rough estimate: half of links are movies
            total + (player.linksContributed / 2)
        }
    }

    private var countActors: Int {
        viewModel.players.reduce(0) { total, player in
            total + ((player.linksContributed + 1) / 2)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.startGame()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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

// MARK: - Player Standing Row

struct PlayerStandingRow: View {
    let rank: Int
    let player: MovieChainPlayer
    let gameMode: MovieChainGameMode
    let isWinner: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)

                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.caption)
                        .foregroundStyle(.white)
                } else {
                    Text("\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            // Player info
            Circle()
                .fill(player.color)
                .frame(width: 16, height: 16)

            Text(player.name)
                .font(.subheadline)
                .fontWeight(isWinner ? .bold : .regular)

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: 2) {
                switch gameMode {
                case .classic:
                    HStack(spacing: 2) {
                        ForEach(0..<gameMode.defaultLives, id: \.self) { index in
                            Image(systemName: index < player.lives ? "heart.fill" : "heart")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                case .timed:
                    Text("\(player.score) pts")
                        .font(.subheadline)
                        .fontWeight(.medium)
                case .endless:
                    Text("\(player.linksContributed) links")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Text("\(player.linksContributed) contributed")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isWinner ? player.color.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }

    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "star.fill"
        default: return ""
        }
    }
}

// MARK: - Game Stat Card

struct GameStatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.red)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MovieChainGameOverView(
        viewModel: {
            let vm = MovieChainViewModel()
            vm.setPlayerCount(3)
            return vm
        }(),
        winner: MovieChainPlayer(name: "Alice", color: .blue, lives: 2)
    )
}
