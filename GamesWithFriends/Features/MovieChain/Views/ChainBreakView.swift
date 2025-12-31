import SwiftUI

/// View shown when the chain is broken
struct ChainBreakView: View {
    @ObservedObject var viewModel: MovieChainViewModel
    let reason: ChainBreakReason

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.red.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Chain break icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: true)
                }

                // Message
                VStack(spacing: 8) {
                    Text("Chain Broken!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(reason.message)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Player who broke the chain
                HStack(spacing: 12) {
                    Circle()
                        .fill(viewModel.currentPlayer.color)
                        .frame(width: 20, height: 20)

                    Text(viewModel.currentPlayer.name)
                        .font(.title3)
                        .fontWeight(.medium)

                    if viewModel.gameMode.hasLives {
                        Text("lost a life")
                            .foregroundStyle(.secondary)

                        HStack(spacing: 2) {
                            ForEach(0..<viewModel.gameMode.defaultLives, id: \.self) { index in
                                Image(systemName: index < viewModel.currentPlayer.lives ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Chain stats
                chainStatsSection

                Spacer()

                // Action buttons
                actionButtons
            }
            .padding()
        }
    }

    // MARK: - Chain Stats Section

    private var chainStatsSection: some View {
        VStack(spacing: 16) {
            Text("Chain Length: \(viewModel.chain.count)")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.chain.count > 1 {
                // Show the chain that was built
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.chain) { link in
                            MiniChainLinkView(link: link)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            HStack(spacing: 24) {
                MovieChainStatBox(
                    title: "Longest Chain",
                    value: "\(viewModel.longestChainThisGame)",
                    icon: "link"
                )

                MovieChainStatBox(
                    title: "Chains Completed",
                    value: "\(viewModel.totalChainsCompleted)",
                    icon: "arrow.triangle.2.circlepath"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Check if game should end (only 1 player left in classic mode)
            if viewModel.gameMode == .classic && viewModel.activePlayers.count <= 1 {
                Button {
                    viewModel.endGame()
                } label: {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("See Results")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Continue with new chain
                Button {
                    viewModel.startNewChain()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Start New Chain")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if viewModel.gameMode == .endless {
                    Button {
                        viewModel.endGame()
                    } label: {
                        Text("End Game")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                viewModel.returnToSetup()
            } label: {
                Text("Quit to Menu")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Mini Chain Link View

struct MiniChainLinkView: View {
    let link: ChainLink

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(link.isMovie ? Color.red : Color.blue)
                    .frame(width: 36, height: 36)

                Image(systemName: link.isMovie ? "film" : "person.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            Text(shortName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
        }
    }

    private var shortName: String {
        let name = link.displayName
        if name.count > 10 {
            return String(name.prefix(8)) + "..."
        }
        return name
    }
}

// MARK: - Stat Box

struct MovieChainStatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.red)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ChainBreakView(
        viewModel: MovieChainViewModel(),
        reason: .invalidAnswer(submitted: "Tom Hanks", expected: "The Matrix")
    )
}
