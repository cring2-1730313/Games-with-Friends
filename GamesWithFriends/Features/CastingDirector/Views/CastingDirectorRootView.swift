import SwiftUI

/// Root view for Casting Director game — manages navigation between game phases
struct CastingDirectorRootView: View {
    @StateObject private var viewModel = CastingDirectorViewModel()

    var body: some View {
        Group {
            switch viewModel.gamePhase {
            case .setup:
                CastingDirectorSetupView(viewModel: viewModel)

            case .playing:
                ClueBoardView(viewModel: viewModel)

            case .roundResult:
                RoundResultsView(viewModel: viewModel)

            case .gameOver:
                CastingDirectorGameOverView(viewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden(viewModel.gamePhase != .setup)
    }
}
