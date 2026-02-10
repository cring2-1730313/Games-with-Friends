import SwiftUI

/// Setup view for configuring Casting Director game
struct CastingDirectorSetupView: View {
    @ObservedObject var viewModel: CastingDirectorViewModel
    @State private var playerCount: Int = 2
    @State private var showingPlayerNames = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    if viewModel.isDatabaseDecompressing {
                        decompressionSection
                    } else if !viewModel.isDatabaseReady {
                        databaseErrorSection
                    }

                    gameModeSection
                    difficultySection

                    if viewModel.gameMode == .passAndPlay {
                        playerCountSection
                        playerNamesSection
                    }

                    roundsSection
                    startButton
                }
                .padding()
            }
        }
        .navigationTitle("Casting Director")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: playerCount) { _, newValue in
            viewModel.setPlayerCount(newValue)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.indigo)

            Text("Guess the actor from clues!")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }

    // MARK: - Decompression

    private var decompressionSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Preparing Movie Database...")
                .font(.headline)

            ProgressView(value: viewModel.decompressionProgress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 200)

            Text("\(Int(viewModel.decompressionProgress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("This only happens once on first launch.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Database Error

    private var databaseErrorSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)

            Text("Database Not Loaded")
                .font(.headline)

            if let error = viewModel.databaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Game Mode

    private var gameModeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Mode")
                .font(.headline)

            ForEach(CastingDirectorMode.allCases, id: \.rawValue) { mode in
                Button {
                    viewModel.gameMode = mode
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: mode == .solo ? "person.fill" : "person.3.fill")
                            .font(.title2)
                            .foregroundStyle(viewModel.gameMode == mode ? .white : .indigo)
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.rawValue)
                                .font(.headline)
                                .foregroundStyle(viewModel.gameMode == mode ? .white : .primary)

                            Text(mode.description)
                                .font(.caption)
                                .foregroundStyle(viewModel.gameMode == mode ? .white.opacity(0.8) : .secondary)
                        }

                        Spacer()

                        if viewModel.gameMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                    .background(viewModel.gameMode == mode ? Color.indigo : Color.clear)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.gameMode == mode ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Difficulty

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Difficulty")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(CastingDirectorDifficulty.allCases, id: \.rawValue) { diff in
                    Button {
                        viewModel.difficulty = diff
                    } label: {
                        VStack(spacing: 6) {
                            Text(diff.rawValue)
                                .font(.headline)
                                .foregroundStyle(viewModel.difficulty == diff ? .white : .primary)

                            Text("\(Int(diff.clueInterval))s per clue")
                                .font(.caption2)
                                .foregroundStyle(viewModel.difficulty == diff ? .white.opacity(0.8) : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.difficulty == diff ? Color.indigo : Color.clear)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.difficulty == diff ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Player Count

    private var playerCountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Players")
                .font(.headline)

            HStack {
                Text("\(playerCount) Players")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        if playerCount > 2 { playerCount -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(playerCount > 2 ? .indigo : .gray)
                    }
                    .disabled(playerCount <= 2)

                    Button {
                        if playerCount < 8 { playerCount += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(playerCount < 8 ? .indigo : .gray)
                    }
                    .disabled(playerCount >= 8)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Player Names

    private var playerNamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Player Names")
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation { showingPlayerNames.toggle() }
                } label: {
                    Image(systemName: showingPlayerNames ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }

            if showingPlayerNames {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Circle()
                                .fill(player.color)
                                .frame(width: 24, height: 24)

                            TextField("Player \(index + 1)", text: Binding(
                                get: { player.name },
                                set: { viewModel.updatePlayerName(at: index, to: $0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Rounds

    private var roundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rounds")
                .font(.headline)

            HStack {
                Text("\(viewModel.numberOfRounds) rounds")
                    .font(.title3)

                Spacer()

                Picker("Rounds", selection: $viewModel.numberOfRounds) {
                    Text("3").tag(3)
                    Text("5").tag(5)
                    Text("10").tag(10)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            viewModel.startGame()
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Game")
            }
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isDatabaseReady ? Color.indigo : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!viewModel.isDatabaseReady)
        .padding(.top)
    }
}
