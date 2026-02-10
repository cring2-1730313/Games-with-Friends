import SwiftUI

/// The main gameplay view — scattered clue board with guess button
struct ClueBoardView: View {
    @ObservedObject var viewModel: CastingDirectorViewModel

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.indigo.opacity(0.15), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Clue board area
                if viewModel.isLoadingRound {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Finding an actor...")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            clueBoard
                                .padding(.horizontal, 8)
                                .padding(.top, 12)
                                .padding(.bottom, 16)
                        }
                        .onChange(of: viewModel.roundState.revealedClues.count) { _, _ in
                            // Auto-scroll to the latest clue
                            if let lastClue = viewModel.roundState.revealedClues.last {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(lastClue.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Bottom bar with score and guess button
                bottomBar
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            // Guess overlay
            if viewModel.showingGuessOverlay {
                GuessOverlayView(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Correct guess celebration
            if viewModel.correctGuess {
                correctGuessOverlay
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showingGuessOverlay)
        .animation(.spring(), value: viewModel.correctGuess)
    }

    // MARK: - Clue Board (scattered stagger layout)

    private var clueBoard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.roundState.revealedClues) { clue in
                let position = viewModel.cluePositions[clue.id]
                let isLatest = clue.id == viewModel.roundState.revealedClues.last?.id
                let alignment = alignmentForClue(clue)

                HStack {
                    if alignment == .trailing || alignment == .center {
                        Spacer(minLength: spacerWidth(for: clue))
                    }

                    ClueChipView(clue: clue, isLatest: isLatest)
                        .frame(maxWidth: chipMaxWidth(for: clue))
                        .rotationEffect(.degrees(position?.rotation ?? 0))
                        .id(clue.id)

                    if alignment == .leading || alignment == .center {
                        Spacer(minLength: 0)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.6).combined(with: .opacity).combined(with: .offset(y: 10)),
                    removal: .opacity
                ))
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.roundState.revealedClues.count)
                .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }

    /// Determine alignment based on clue order to create scattered feel
    private func alignmentForClue(_ clue: Clue) -> HorizontalAlignment {
        // Use a deterministic but varied pattern based on clue order
        let pattern = clue.orderNumber % 3
        switch pattern {
        case 0: return .leading
        case 1: return .trailing
        default: return .center
        }
    }

    /// Variable spacer width to add organic offset within the chosen alignment
    private func spacerWidth(for clue: Clue) -> CGFloat {
        guard let position = viewModel.cluePositions[clue.id] else { return 0 }
        // Use the xFraction from the position data to create varied indentation
        return CGFloat(position.xFraction) * 60
    }

    /// Constrain chip width so they never exceed screen width
    private func chipMaxWidth(for clue: Clue) -> CGFloat {
        // Shorter clues get a tighter max width; longer clues can use more space
        let baseWidth: CGFloat = 280
        // Tier 4 clues (movie titles) tend to be longer
        switch clue.tier {
        case .vague: return baseWidth - 20
        case .narrowing: return baseWidth
        case .strongSignal: return baseWidth + 10
        case .giveaway: return baseWidth + 20
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Round info
            VStack(alignment: .leading, spacing: 2) {
                Text("Round \(viewModel.currentRound) of \(viewModel.numberOfRounds)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if viewModel.gameMode == .passAndPlay {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.currentPlayer.color)
                            .frame(width: 10, height: 10)
                        Text(viewModel.currentPlayer.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }

            Spacer()

            // Clue counter
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("\(viewModel.roundState.cluesRevealed)/\(viewModel.allClues.count)")
                    .font(.subheadline)
                    .monospacedDigit()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())

            // Difficulty badge
            Text(viewModel.difficulty.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.indigo.opacity(0.2))
                .clipShape(Capsule())
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 16) {
            // Give up button
            Button {
                viewModel.giveUp()
            } label: {
                Text("Give Up")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            // Score display
            VStack(spacing: 2) {
                Text("Score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.potentialScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.indigo)
                    .contentTransition(.numericText())
                    .animation(.spring(), value: viewModel.potentialScore)
            }

            Spacer()

            // Guess button
            Button {
                viewModel.showingGuessOverlay = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Guess")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.indigo)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .modifier(ShakeEffect(shakes: viewModel.wrongGuessShake ? 4 : 0))
            .animation(.default, value: viewModel.wrongGuessShake)
        }
    }

    // MARK: - Correct Guess Overlay

    private var correctGuessOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: viewModel.correctGuess)

            if let actor = viewModel.roundState.targetActor {
                Text(actor.name)
                    .font(.title)
                    .fontWeight(.bold)
            }

            Text("+\(viewModel.roundState.currentScore) points!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
        }
        .padding(40)
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 2) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
