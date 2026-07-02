import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Fetching Live Trivia...")
                    .progressViewStyle(CircularProgressViewStyle())
                
            case .failed:
                VStack(spacing: 20) {
                    Text("Network Error!")
                        .font(.title)
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.loadGame() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            case .loaded:
                gameplayInterface
                
            case .finished:
                resultsSummary
            }
        }
        // Fetch data immediately when the view appears
        .task {
            await viewModel.loadGame()
        }
    }
    
    // MARK: - Gameplay Interface
    private var gameplayInterface: some View {
        VStack(spacing: 20) {
            // Header stats
            HStack {
                Text("Question: \(viewModel.currentIndex + 1) / 10")
                Spacer()
                Text("Streak: \(viewModel.streak) 🔥")
                Spacer()
                Text("Score: \(viewModel.score)")
            }
            .font(.subheadline)
            .padding()
            
            Spacer()
            
            // Question Display
            if let current = viewModel.currentQuestion {
                Text(current.question)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                // 4 Answer Buttons
                VStack(spacing: 12) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        Button(action: {
                            withAnimation {
                                viewModel.handleAnswer(answer)
                            }
                        }) {
                            Text(answer)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Results Summary
    private var resultsSummary: some View {
        VStack(spacing: 20) {
            Text("Round Finished!")
                .font(.largeTitle)
                .bold()
            
            Text("Final Score: \(viewModel.score)")
                .font(.title2)
            
            Button("Play Again") {
                Task { await viewModel.loadGame() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
