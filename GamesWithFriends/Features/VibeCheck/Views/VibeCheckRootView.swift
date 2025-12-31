import SwiftUI

struct VibeCheckRootView: View {
    @StateObject private var viewModel = VibeCheckViewModel()

    var body: some View {
        Group {
            switch viewModel.gameState {
            case .setup:
                VibeCheckHomeView(viewModel: viewModel)

            case .teamSetup:
                TeamSetupView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .passingToPromptSetter:
                PromptSetterPassView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .promptEntry:
                PromptEntryView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .passingToGuessingTeam:
                GuessingTeamPassView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .guessing:
                TeamGuessingView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .reveal:
                RevealView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

            case .scoreboard:
                ScoreboardView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .gameOver:
                VibeCheckGameOverView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState)
    }
}

#Preview {
    VibeCheckRootView()
}
