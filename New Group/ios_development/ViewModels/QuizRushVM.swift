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
    var locationService: LocationService

    // ── Current difficulty being played ──
    @Published var difficulty: QuizDifficulty = .easy

    @Published var state: GameState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var currentAnswers: [String] = []
    @Published var storedHighScore: Int = 0
    @Published var correctCount: Int = 0
    @Published var wrongCount: Int = 0
    @Published var errorMessage: String? = nil

    // ── Result of the finished game ──
    @Published var passed: Bool = false

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var totalQuestions: Int { questions.count }
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(correctCount) / Double(totalQuestions)) * 100
    }

    init(locationService: LocationService) {
        self.locationService = locationService
        self.storedHighScore = UserDefaults.standard.integer(forKey: difficulty.highScoreKey)
    }

    // Call this whenever a new difficulty is selected before loading.
    func setDifficulty(_ diff: QuizDifficulty) {
        difficulty = diff
        storedHighScore = UserDefaults.standard.integer(forKey: diff.highScoreKey)
    }

    func loadGame() async {
        await MainActor.run {
            state = .loading
            errorMessage = nil
        }
        do {
            let fetched = try await api.fetchQuestions(difficulty: difficulty)
            await MainActor.run {
                self.questions     = fetched
                self.currentIndex  = 0
                self.score         = 0
                self.streak        = 0
                self.correctCount  = 0
                self.wrongCount    = 0
                self.passed        = false
                prepareAnswers()
                state = .loaded
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                state = .failed
            }
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
            correctCount += 1
            score += 10 + (streak * 2)
            streak += 1
        } else {
            wrongCount += 1
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
        // Determine pass/fail
        passed = correctCount >= difficulty.passMarkCorrect

        // Persist completion so the next difficulty unlocks
        if passed {
            UserDefaults.standard.set(true, forKey: difficulty.completedKey)
        }

        // Update high score for this difficulty
        if score > storedHighScore {
            storedHighScore = score
            UserDefaults.standard.set(storedHighScore, forKey: difficulty.highScoreKey)
        }

        state = .finished
        saveGameSession()
    }

    private func saveGameSession() {
        let lat = locationService.lastLocation?.coordinate.latitude  ?? 0.0
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

    func updateLocationService(_ service: LocationService) {
        self.locationService = service
    }
}
