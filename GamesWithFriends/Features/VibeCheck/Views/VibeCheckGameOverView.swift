import SwiftUI

struct VibeCheckGameOverView: View {
    @ObservedObject var viewModel: VibeCheckViewModel
    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 24) {
            // Header with winner
            winnerSection

            // Final standings
            standingsSection

            Spacer()

            // Play again button
            playAgainButton
        }
        .padding()
        .background {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if showConfetti {
                    ConfettiView()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                showConfetti = true
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    // MARK: - Sections

    private var winnerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .yellow.opacity(0.5), radius: 10)

            Text("GAME OVER!")
                .font(.largeTitle.weight(.bold))

            if let winner = viewModel.winner {
                VStack(spacing: 8) {
                    Text("\(winner.name) Wins!")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.purple)

                    Text("\(winner.score) points")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    private var standingsSection: some View {
        VStack(spacing: 16) {
            Text("FINAL STANDINGS")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(Array(viewModel.sortedTeamsByScore.enumerated()), id: \.element.id) { index, team in
                FinalTeamRow(
                    rank: index + 1,
                    team: team,
                    isWinner: index == 0
                )

                if index < viewModel.sortedTeamsByScore.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }

    private var playAgainButton: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.resetGame()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("PLAY AGAIN")
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

            Button {
                viewModel.returnToSetup()
            } label: {
                Text("Back to Setup")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Final Team Row

struct FinalTeamRow: View {
    let rank: Int
    let team: VibeCheckTeam
    let isWinner: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Rank with medal for top 3
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(medalColor)
                        .frame(width: 36, height: 36)

                    if rank == 1 {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(rank)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                } else {
                    Text("\(rank).")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 36)
                }
            }

            // Team info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(team.name)
                        .font(.headline)

                    if isWinner {
                        Text("WINNER")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(Color.purple)
                            }
                    }
                }

                Text(team.playerNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(team.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("points")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
}

// MARK: - Confetti Effect

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.purple, .blue, .yellow, .green, .orange, .pink]
        particles = (0..<50).map { _ in
            ConfettiParticle(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -50...50),
                    y: CGFloat.random(in: 200...400)
                ),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        withAnimation(.linear(duration: 3)) {
            for i in particles.indices {
                particles[i].position.y += particles[i].velocity.y
                particles[i].position.x += particles[i].velocity.x
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    let velocity: CGPoint
    var opacity: Double
}

#Preview {
    let viewModel = VibeCheckViewModel()
    viewModel.settings.teamCount = 2
    viewModel.settings.playersPerTeam = 3
    viewModel.proceedToTeamSetup()
    viewModel.teams[0].score = 520
    viewModel.teams[1].score = 380
    return VibeCheckGameOverView(viewModel: viewModel)
}
