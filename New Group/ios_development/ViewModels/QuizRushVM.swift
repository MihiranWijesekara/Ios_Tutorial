import SwiftUI
import Combine
import CoreLocation

class QuizRushVM: ObservableObject {
    enum GameState {
        case loading
        case loaded
        case failed
        case finished
    }
    
    private let api = TriviaAPI()
    private let locationService: LocationService
    
    @Published var state: GameState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var currentAnswers: [String] = []
    @Published var storedHighScore = 0
    
    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.storedHighScore = UserDefaults.standard.integer(forKey: "highScore_quizRush")
    }
    
    func loadGame() async {
        state = .loading
        do {
            self.questions = try await api.fetchQuestions()
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
            score += 10 + (streak * 2)
            streak += 1
        } else {
            score = max(0, score - 5)
            streak = 0
        }
        
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            prepareAnswers()
        } else {
            endGame()
        }
    }
    
    private func endGame() {
        state = .finished
        if score > storedHighScore {
            storedHighScore = score
            UserDefaults.standard.set(storedHighScore, forKey: "highScore_quizRush")
        }
        saveGameSession()
    }
    
    private func saveGameSession() {
        let lat = locationService.lastLocation?.coordinate.latitude ?? 0.0
        let lon = locationService.lastLocation?.coordinate.longitude ?? 0.0
        
        let newSession = GameSession(
            id: UUID(),
            mode: .quizRush,
            score: score,
            timestamp: Date(),
            latitude: lat,
            longitude: lon
        )
        
        appendSession(newSession)
    }
    
    private func appendSession(_ session: GameSession) {
        var sessions = loadSessions()
        sessions.append(session)
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "game_sessions")
        }
    }
    
    private func loadSessions() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: "game_sessions") else { return [] }
        return (try? JSONDecoder().decode([GameSession].self, from: data)) ?? []
    }
}
