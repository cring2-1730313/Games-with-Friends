import SwiftUI

/// Root view for Movie Chain game - manages navigation between game phases
struct MovieChainRootView: View {
    @StateObject private var viewModel = MovieChainViewModel()

    var body: some View {
        Group {
            switch viewModel.gamePhase {
            case .setup:
                MovieChainSetupView(viewModel: viewModel)

            case .playing:
                MovieChainGameView(viewModel: viewModel)

            case .chainBroken(let reason):
                ChainBreakView(viewModel: viewModel, reason: reason)

            case .gameOver(let winner):
                MovieChainGameOverView(viewModel: viewModel, winner: winner)
            }
        }
        .navigationBarBackButtonHidden(viewModel.gamePhase != .setup)
    }
}

#Preview {
    NavigationStack {
        MovieChainRootView()
    }
}
