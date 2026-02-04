import SwiftUI

struct CompetitionRevealView: View {
    @ObservedObject var viewModel: CompetitionVibeCheckViewModel
    @State private var showResults = false
    @State private var revealedPositions = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerSection

            ScrollView {
                VStack(spacing: 20) {
                    // The prompt
                    promptCard

                    // Spectrum with all positions revealed
                    if let round = viewModel.currentRound {
                        multiGuessRevealSection(round: round)
                    }

                    // Leaderboard results
                    if showResults {
                        leaderboardSection
                    }
                }
            }

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
                .foregroundStyle(.orange)
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

            if let setter = viewModel.vibeSetter {
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
    private func multiGuessRevealSection(round: CompetitionRound) -> some View {
        let results = viewModel.getRoundResults()

        VStack(spacing: 16) {
            CompetitionRevealSliderView(
                spectrum: round.spectrum,
                targetPosition: round.targetPosition,
                results: results
            )
            .opacity(revealedPositions ? 1 : 0)
            .scaleEffect(revealedPositions ? 1 : 0.9)

            // Legend
            HStack(spacing: 20) {
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
                        .strokeBorder(Color.primary, lineWidth: 2)
                        .frame(width: 12, height: 12)
                    Text("Guesses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var leaderboardSection: some View {
        VStack(spacing: 16) {
            Text("LEADERBOARD")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(2)

            ForEach(viewModel.getRoundResults()) { result in
                CompetitionResultRow(
                    result: result,
                    isWorst: result.id == viewModel.worstGuesser?.id,
                    totalPlayers: viewModel.guessingPlayers.count
                )
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
                    colors: [.orange, .red],
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

// MARK: - Multi-Guess Reveal Slider

struct CompetitionRevealSliderView: View {
    let spectrum: VibeCheckSpectrum
    let targetPosition: Double
    let results: [CompetitionRoundResult]

    private let sliderHeight: CGFloat = 300
    private let trackWidth: CGFloat = 60

    // Player colors for differentiation
    private let playerColors: [Color] = [
        .blue, .purple, .pink, .cyan, .indigo, .mint, .teal, .brown, .gray
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Top label
            Text(spectrum.topLabel.uppercased())
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            // Slider with all positions
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background track
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: trackWidth)
                        .frame(maxWidth: .infinity)

                    // Scoring zones
                    scoringZonesView(height: geometry.size.height)

                    // Target line (green)
                    targetLine(height: geometry.size.height)

                    // All guess lines
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                        guessLine(
                            result: result,
                            height: geometry.size.height,
                            color: playerColors[index % playerColors.count],
                            index: index
                        )
                    }
                }
            }
            .frame(height: sliderHeight)

            // Bottom label
            Text(spectrum.bottomLabel.uppercased())
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal)
    }

    private func scoringZonesView(height: CGFloat) -> some View {
        let targetY = targetPosition * height

        return Canvas { context, size in
            let centerX = size.width / 2

            for zone in ScoringZone.allCases.reversed() {
                let zoneHalfHeight = zone.threshold * height
                let topY = max(0, targetY - zoneHalfHeight)
                let bottomY = min(height, targetY + zoneHalfHeight)
                let zoneHeight = bottomY - topY

                let rect = CGRect(
                    x: centerX - trackWidth / 2 + CGFloat(4),
                    y: topY,
                    width: trackWidth - 8,
                    height: zoneHeight
                )

                context.fill(
                    Path(roundedRect: rect, cornerRadius: 6),
                    with: .color(zone.color.opacity(0.4))
                )
            }
        }
    }

    private func targetLine(height: CGFloat) -> some View {
        let y = targetPosition * height

        return HStack(spacing: 4) {
            Text("Target")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.green)
                .frame(width: 45, alignment: .trailing)

            Rectangle()
                .fill(Color.green)
                .frame(width: trackWidth + 20, height: 4)
                .shadow(color: .black.opacity(0.2), radius: 2)

            Circle()
                .fill(Color.green)
                .frame(width: 14, height: 14)
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                }
        }
        .position(x: UIScreen.main.bounds.width / 2 - 16, y: y)
    }

    private func guessLine(result: CompetitionRoundResult, height: CGFloat, color: Color, index: Int) -> some View {
        let y = result.guessedPosition * height
        // Slight offset to prevent exact overlapping
        let xOffset = CGFloat(index % 2 == 0 ? -2 : 2)

        return HStack(spacing: 4) {
            Text(result.playerName)
                .font(.caption2.weight(.medium))
                .foregroundStyle(color)
                .frame(width: 45, alignment: .trailing)
                .lineLimit(1)

            Rectangle()
                .fill(color)
                .frame(width: trackWidth + 20, height: 3)
                .shadow(color: .black.opacity(0.15), radius: 1)

            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                }
        }
        .position(x: UIScreen.main.bounds.width / 2 - 16 + xOffset, y: y)
    }
}

// MARK: - Result Row

struct CompetitionResultRow: View {
    let result: CompetitionRoundResult
    let isWorst: Bool
    let totalPlayers: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Rank indicator
                rankBadge

                // Player info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(result.playerName)
                            .font(.headline)

                        if result.rank == 1 {
                            Text("CLOSEST")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(Color.green)
                                }
                        }
                    }

                    Text("\(result.distancePercentage)% away")
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

            // Worst guesser tease
            if isWorst && totalPlayers > 1 {
                HStack(spacing: 6) {
                    Image(systemName: "face.smiling.inverse")
                        .foregroundStyle(.orange)
                    Text(WorstGuesserTease.randomMessage())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }

    private var rankBadge: some View {
        ZStack {
            if result.rank == 1 {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 32, height: 32)

                Image(systemName: "crown.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            } else if result.rank == 2 {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)

                Text("2")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
            } else if result.rank == 3 {
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

                Text("\(result.rank)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
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
    viewModel.startGame()
    viewModel.confirmVibeSetterReady()
    viewModel.currentPrompt = "Clipping your nails in a movie theater"
    viewModel.submitPrompt()
    // Simulate some guesses
    viewModel.confirmGuessingPlayerReady()
    viewModel.currentGuessPosition = 0.18
    viewModel.submitGuess()
    viewModel.confirmGuessingPlayerReady()
    viewModel.currentGuessPosition = 0.25
    viewModel.submitGuess()
    viewModel.confirmGuessingPlayerReady()
    viewModel.currentGuessPosition = 0.45
    viewModel.submitGuess()
    return CompetitionRevealView(viewModel: viewModel)
}
