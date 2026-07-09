import SwiftUI

struct QuizRushView: View {
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel: QuizRushVM
    
    init(locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: QuizRushVM(locationService: locationService))
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .loading:
                ProgressView("Fetching Live Trivia...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(.white)
                
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
                ResultView(
                    score: viewModel.score,
                    highScore: viewModel.storedHighScore,
                    gameMode: .quizRush,
                    onPlayAgain: {
                        Task { await viewModel.loadGame() }
                    }
                )
            }
        }
        .task {
            await viewModel.loadGame()
        }
    }
    
    private var gameplayInterface: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Question: \(viewModel.currentIndex + 1) / 10")
                Spacer()
                Text("Streak: \(viewModel.streak) 🔥")
                Spacer()
                Text("Score: \(viewModel.score)")
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            
            Spacer()
            
            if let current = viewModel.currentQuestion {
                Text(current.question)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        Button(action: {
                            withAnimation {
                                viewModel.handleAnswer(answer)
                            }
                        }) {
                            Text(answer)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
        }
    }
}
