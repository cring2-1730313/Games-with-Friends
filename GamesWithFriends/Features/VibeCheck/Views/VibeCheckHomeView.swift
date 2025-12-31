import SwiftUI

struct VibeCheckHomeView: View {
    @ObservedObject var viewModel: VibeCheckViewModel
    @State private var showHowToPlay = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Team count
                teamCountSection

                // Players per team
                playersPerTeamSection

                // Target score
                targetScoreSection

                // Continue button
                continueButton

                // How to play
                Button {
                    showHowToPlay = true
                } label: {
                    Label("How to Play", systemImage: "book.fill")
                        .font(.subheadline)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background {
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayView()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("VIBE CHECK")
                .font(.largeTitle.weight(.bold))

            Text("Get on the same wavelength")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }

    private var teamCountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Teams", systemImage: "person.3.fill")
                .font(.headline)

            HStack {
                Button {
                    if viewModel.settings.teamCount > 1 {
                        viewModel.settings.teamCount -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.settings.teamCount > 1 ? .primary : .secondary)
                }
                .disabled(viewModel.settings.teamCount <= 1)

                Spacer()

                Text("\(viewModel.settings.teamCount)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Spacer()

                Button {
                    if viewModel.settings.teamCount < 4 {
                        viewModel.settings.teamCount += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.settings.teamCount < 4 ? .primary : .secondary)
                }
                .disabled(viewModel.settings.teamCount >= 4)
            }
            .padding(.horizontal)

            Text(viewModel.settings.teamCount == 1 ? "Single team mode" : "1-4 teams")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    private var playersPerTeamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Players per Team", systemImage: "person.2.fill")
                .font(.headline)

            HStack {
                Button {
                    if viewModel.settings.playersPerTeam > 2 {
                        viewModel.settings.playersPerTeam -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.settings.playersPerTeam > 2 ? .primary : .secondary)
                }
                .disabled(viewModel.settings.playersPerTeam <= 2)

                Spacer()

                Text("\(viewModel.settings.playersPerTeam)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Spacer()

                Button {
                    if viewModel.settings.playersPerTeam < 8 {
                        viewModel.settings.playersPerTeam += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.settings.playersPerTeam < 8 ? .primary : .secondary)
                }
                .disabled(viewModel.settings.playersPerTeam >= 8)
            }
            .padding(.horizontal)

            Text("Minimum 2 players per team")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    private var targetScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Target Score", systemImage: "flag.checkered")
                .font(.headline)

            HStack(spacing: 16) {
                ForEach([300, 500, 750, 1000], id: \.self) { score in
                    Button {
                        viewModel.settings.targetScore = score
                    } label: {
                        Text("\(score)")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewModel.settings.targetScore == score ? Color.purple : Color(.systemGray5))
                            }
                            .foregroundStyle(viewModel.settings.targetScore == score ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    private var continueButton: some View {
        Button {
            viewModel.proceedToTeamSetup()
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("SET UP TEAMS")
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
    }
}

// MARK: - Team Setup View

struct TeamSetupView: View {
    @ObservedObject var viewModel: VibeCheckViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Set Up Teams")
                    .font(.title.weight(.bold))

                // Team cards
                ForEach(Array(viewModel.teams.enumerated()), id: \.element.id) { teamIndex, team in
                    TeamSetupCard(
                        teamIndex: teamIndex,
                        team: team,
                        viewModel: viewModel
                    )
                }

                // Start button
                startButton
            }
            .padding()
        }
        .background {
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private var startButton: some View {
        Button {
            viewModel.startGame()
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("START GAME")
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
    }
}

struct TeamSetupCard: View {
    let teamIndex: Int
    let team: VibeCheckTeam
    @ObservedObject var viewModel: VibeCheckViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Team name
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(.purple)
                TextField("Enter team name", text: Binding(
                    get: { team.name },
                    set: { viewModel.updateTeamName(at: teamIndex, name: $0) }
                ))
                .font(.headline)
                .foregroundStyle(.primary)
            }

            Divider()

            // Player names
            ForEach(Array(team.playerNames.enumerated()), id: \.offset) { playerIndex, playerName in
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    TextField("Player \(playerIndex + 1)", text: Binding(
                        get: { playerName },
                        set: { viewModel.updatePlayerName(teamIndex: teamIndex, playerIndex: playerIndex, name: $0) }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

// MARK: - How To Play

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Overview
                    section(title: "Overview", icon: "info.circle.fill") {
                        Text("A spectrum with polar opposites is shown (e.g., Trashy ↔ Classy). One player sees a target position and creates a prompt that matches it. The team then tries to guess where the prompt falls on the spectrum.")
                    }

                    // Prompt Setter
                    section(title: "Prompt Setter", icon: "person.fill.questionmark") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. See the spectrum and target position")
                            Text("2. Think of something that matches that position")
                            Text("3. Example: Target is near 'Trashy' → 'Clipping your nails in a movie theater'")
                        }
                    }

                    // Guessing
                    section(title: "Guessing Team", icon: "hand.tap.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. See the spectrum and the prompt")
                            Text("2. Discuss as a team")
                            Text("3. Slide to where you think it belongs")
                            Text("4. Lock in your guess!")
                        }
                    }

                    // Scoring
                    section(title: "Scoring Zones", icon: "target") {
                        VStack(alignment: .leading, spacing: 12) {
                            scoringRow(.perfect)
                            scoringRow(.great)
                            scoringRow(.good)
                            scoringRow(.okay)
                            scoringRow(.miss)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func section<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.purple)

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }

    private func scoringRow(_ zone: ScoringZone) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(zone.color)
                .frame(width: 16, height: 16)

            Text("\(zone.points) points")
                .font(.subheadline.weight(.medium))

            Text("(within \(Int(zone.threshold * 100))%)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VibeCheckHomeView(viewModel: VibeCheckViewModel())
}
