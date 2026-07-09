import SwiftUI

struct QuizRushContainerView: View {
    @EnvironmentObject var locationService: LocationService

    @StateObject private var vm = QuizRushVM(locationService: LocationService())

    /// Drives whether the difficulty picker is shown instead of the game flow.
    @State private var isSelectingDifficulty = true

    var body: some View {
        ZStack {
            if isSelectingDifficulty {
                // ── Difficulty picker ──
                QuizDifficultyPickerView(viewModel: vm)
                    .transition(.opacity)

            } else {
                // ── Game flow ──
                switch vm.state {
                case .loading:
                    ProgressView("Loading \(vm.difficulty.displayName) Questions…")
                        .foregroundColor(.white)
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
                            .foregroundColor(.white)
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

                        Button("Change Difficulty") {
                            withAnimation { isSelectingDifficulty = true }
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }

                case .finished:
                    QuizResultView(
                        score: vm.score,
                        highScore: vm.storedHighScore,
                        correct: vm.correctCount,
                        wrong: vm.wrongCount,
                        total: vm.totalQuestions,
                        difficulty: vm.difficulty,
                        passed: vm.passed
                    ) {
                        // Play Again — same difficulty
                        Task { await vm.loadGame() }
                    } onChangeDifficulty: {
                        withAnimation { isSelectingDifficulty = true }
                    }
                }
            }
        }
        // When the VM transitions out of loading it means a difficulty was chosen
        .onChange(of: vm.state) { newState in
            if newState == .loaded || newState == .failed {
                withAnimation { isSelectingDifficulty = false }
            }
        }
        .onAppear {
            vm.updateLocationService(locationService)
            // Always start at the picker
            isSelectingDifficulty = true
        }
        .toolbar(.hidden, for: .tabBar)
    }
}
