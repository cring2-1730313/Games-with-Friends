import SwiftUI

struct CompetitionVibeCheckRootView: View {
    @StateObject private var viewModel = CompetitionVibeCheckViewModel()

    var body: some View {
        Group {
            switch viewModel.gameState {
            case .setup:
                CompetitionHomeView(viewModel: viewModel)

            case .playerSetup:
                CompetitionPlayerSetupView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .passingToVibeSetter:
                CompetitionVibeSetterPassView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .promptEntry:
                CompetitionPromptEntryView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .passingToGuesser:
                CompetitionGuesserPassView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .guessing:
                CompetitionGuessingView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .reveal:
                CompetitionRevealView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))

            case .scoreboard:
                CompetitionScoreboardView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))

            case .gameOver:
                CompetitionGameOverView(viewModel: viewModel)
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
    CompetitionVibeCheckRootView()
}
