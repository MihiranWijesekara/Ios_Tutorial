import SwiftUI

struct QuizRushContainerView: View {
    @EnvironmentObject var locationService: LocationService

    @StateObject private var vm = QuizRushVM(locationService: LocationService())

    var body: some View {
        ZStack {
            switch vm.state {
            case .loading:
                ProgressView("Loading Questions…")
                    .task { await vm.loadGame() }

            case .loaded:
                QuizRushView(viewModel: vm)

            case .failed:
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Failed to load questions.")
                        .font(.headline)
                    if let msg = vm.errorMessage {
                        Text(msg)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Button("Retry") {
                        Task { await vm.loadGame() }
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .finished:
                QuizResultView(
                    score: vm.score,
                    highScore: vm.storedHighScore,
                    correct: vm.correctCount,
                    wrong: vm.wrongCount,
                    total: vm.totalQuestions
                ) {
                    Task { await vm.loadGame() }
                }
            }
        }
        .onAppear {
            vm.updateLocationService(locationService)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
