import SwiftUI
import Combine

@MainActor
class QuizRushViewModel: ObservableObject {
    enum GameState {
        case loading
        case loaded
        case failed
        case finished
    }
    
    private let service = TriviaService()
    
    @Published var state: GameState = .loading
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    
    // Pre-shuffled answers for the current question to prevent re-shuffling on view refreshes
    @Published var currentAnswers: [String] = []
    
    var currentQuestion: Question? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    func loadGame() async {
        state = .loading
        do {
            self.questions = try await service.fetchQuestions()
            self.currentIndex = 0
            self.score = 0
            self.streak = 0
            prepareAnswers()
            state = .loaded
        } catch {
            state = .failed
        }
    }
    
    private func prepareAnswers() {
        if let current = currentQuestion {
            currentAnswers = current.allAnswers
        }
    }
    
    func handleAnswer(_ selectedAnswer: String) {
        guard let current = currentQuestion else { return }
        
        if selectedAnswer == current.correctAnswer {
            score += 10 + (streak * 2) // Base points + streak bonus
            streak += 1
        } else {
            score = max(0, score - 5) // Small penalty
            streak = 0
        }
        
        // Advance or Finish
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            prepareAnswers()
        } else {
            state = .finished
        }
    }
}
