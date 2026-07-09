import SwiftUI
import Combine
import CoreLocation

class LightItUpVM: ObservableObject {
    @Published var cards: [Card] = []
    @Published var score = 0
    @Published var lives = 3
    @Published var timeRemaining = 60
    @Published var currentLevel: GameLevel = .L1
    @Published var isPlaying = false
    
    @Published var showGameOver = false
    @Published var gameOverReason = ""
    @Published var showLevelCompleteModal = false
    @Published var showVictoryModal = false
    @Published var levelUpFlash = false
    
    private var gameTimer: Timer?
    private var flashTimer: Timer?
    
    private let locationService: LocationService
    @Published var storedHighScore = 0
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.storedHighScore = UserDefaults.standard.integer(forKey: "highScore_lightItUp")
    }
    
    func startGame() {
        score = 0
        lives = 3
        timeRemaining = 60
        currentLevel = .L1
        showGameOver = false
        showLevelCompleteModal = false
        showVictoryModal = false
        isPlaying = true
        generateCards()
        setupGameClock()
        setupFlashIntervalClock()
    }
    
    func generateCards() {
        cards = (0..<currentLevel.cardCount).map { _ in Card() }
        cycleLitCards()
    }
    
    func setupGameClock() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.isPlaying && !self.showLevelCompleteModal && !self.showVictoryModal && !self.showGameOver else { return }
            
            if self.timeRemaining > 1 {
                self.timeRemaining -= 1
            } else {
                self.timeRemaining = 0
                self.gameOverReason = "Out of Time!"
                self.endGame()
            }
        }
    }
    
    func setupFlashIntervalClock() {
        flashTimer?.invalidate()
        flashTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.isPlaying && !self.showLevelCompleteModal && !self.showVictoryModal && !self.showGameOver else { return }
            self.cycleLitCards()
        }
    }
    
    func cycleLitCards() {
        for i in 0..<cards.count { cards[i].isLit = false }
        
        let countToLit = min(currentLevel.simultaneousLitCount, cards.count)
        var litIndices = Set<Int>()
        
        while litIndices.count < countToLit {
            let randomIndex = Int.random(in: 0..<cards.count)
            litIndices.insert(randomIndex)
        }
        
        withAnimation(.snappy(duration: 0.15)) {
            for index in litIndices {
                self.cards[index].isLit = true
            }
        }
    }
    
    func handleTap(on card: Card) {
        guard !showLevelCompleteModal && !showVictoryModal && !showGameOver else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            score += 10
            cards[index].isLit = false
            checkScoreProgression()
        } else {
            applyPenalty()
        }
    }
    
    func checkScoreProgression() {
        if score >= currentLevel.targetScore {
            if let _ = currentLevel.next() {
                pauseGameForModal()
                withAnimation {
                    showLevelCompleteModal = true
                }
            } else {
                pauseGameForModal()
                withAnimation {
                    showVictoryModal = true
                }
            }
        }
    }
    
    func pauseGameForModal() {
        for i in 0..<cards.count { cards[i].isLit = false }
        cleanUpTimers()
    }
    
    func advanceToNextLevel() {
        if let nextLevel = currentLevel.next() {
            currentLevel = nextLevel
            showLevelCompleteModal = false
            
            withAnimation(.easeInOut(duration: 0.2)) {
                levelUpFlash = true
            }
            
            generateCards()
            setupGameClock()
            setupFlashIntervalClock()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.levelUpFlash = false }
            }
        }
    }
    
    func applyPenalty() {
        if lives > 1 {
            lives -= 1
        } else {
            lives = 0
            gameOverReason = "No Lives Remaining!"
            endGame()
        }
    }
    
    func endGame() {
        isPlaying = false
        cleanUpTimers()
        if score > storedHighScore {
            storedHighScore = score
            UserDefaults.standard.set(storedHighScore, forKey: "highScore_lightItUp")
        }
        
        saveGameSession()
        
        withAnimation { showGameOver = true }
    }
    
    func cleanUpTimers() {
        gameTimer?.invalidate()
        flashTimer?.invalidate()
        gameTimer = nil
        flashTimer = nil
    }
    
    private func saveGameSession() {
        let lat = locationService.lastLocation?.coordinate.latitude ?? 0.0
        let lon = locationService.lastLocation?.coordinate.longitude ?? 0.0
        
        let newSession = GameSession(
            id: UUID(),
            mode: .lightItUp,
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
