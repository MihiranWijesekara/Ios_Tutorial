import SwiftUI
import Combine

class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []
    
    init() {
        loadSessions()
    }
    
    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: "game_sessions") else {
            self.sessions = []
            return
        }
        self.sessions = (try? JSONDecoder().decode([GameSession].self, from: data)) ?? []
    }
    
    var totalGamesPlayed: Int {
        sessions.count
    }
    
    func totalScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.reduce(0) { $0 + $1.score }
    }
    
    func personalBest(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
    
    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }
    
    func resetStats() {
        UserDefaults.standard.removeObject(forKey: "game_sessions")
        UserDefaults.standard.removeObject(forKey: "highScore_tapFrenzy")
        UserDefaults.standard.removeObject(forKey: "highScore_lightItUp")
        UserDefaults.standard.removeObject(forKey: "highScore_quizRush")
        loadSessions()
    }
}
