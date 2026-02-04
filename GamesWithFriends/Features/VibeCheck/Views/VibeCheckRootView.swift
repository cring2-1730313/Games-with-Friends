import SwiftUI

struct VibeCheckRootView: View {
    @StateObject private var classicViewModel = VibeCheckViewModel()
    @StateObject private var competitionViewModel = CompetitionVibeCheckViewModel()
    @State private var selectedMode: VibeCheckGameMode = .classic

    var body: some View {
        Group {
            if selectedMode == .classic {
                classicModeView
            } else {
                competitionModeView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: classicViewModel.gameState)
        .animation(.easeInOut(duration: 0.3), value: competitionViewModel.gameState)
    }

    // MARK: - Classic Mode

    @ViewBuilder
    private var classicModeView: some View {
        switch classicViewModel.gameState {
        case .setup:
            VibeCheckHomeView(viewModel: classicViewModel, selectedMode: $selectedMode)

        case .teamSetup:
            TeamSetupView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .passingToPromptSetter:
            PromptSetterPassView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .promptEntry:
            PromptEntryView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .passingToGuessingTeam:
            GuessingTeamPassView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .guessing:
            TeamGuessingView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .reveal:
            RevealView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))

        case .scoreboard:
            ScoreboardView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .gameOver:
            VibeCheckGameOverView(viewModel: classicViewModel)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
        }
    }

    // MARK: - Competition Mode

    @ViewBuilder
    private var competitionModeView: some View {
        switch competitionViewModel.gameState {
        case .setup:
            // Show home view but competition settings will be used
            VibeCheckHomeView(viewModel: classicViewModel, selectedMode: $selectedMode)
                .onChange(of: classicViewModel.gameState) { _, newState in
                    if newState == .teamSetup && selectedMode == .competition {
                        // Transfer settings and start competition flow
                        competitionViewModel.settings = classicViewModel.competitionSettings
                        competitionViewModel.proceedToPlayerSetup()
                        // Reset classic view model state
                        classicViewModel.gameState = .setup
                    }
                }

        case .playerSetup:
            CompetitionPlayerSetupView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .passingToVibeSetter:
            CompetitionVibeSetterPassView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .promptEntry:
            CompetitionPromptEntryView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .passingToGuesser:
            CompetitionGuesserPassView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .guessing:
            CompetitionGuessingView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .reveal:
            CompetitionRevealView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))

        case .scoreboard:
            CompetitionScoreboardView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

        case .gameOver:
            CompetitionGameOverView(viewModel: competitionViewModel)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
        }
    }
}

#Preview {
    VibeCheckRootView()
}
