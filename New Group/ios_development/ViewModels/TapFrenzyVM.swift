import SwiftUI
import Combine
import CoreLocation

class TapFrenzyVM: ObservableObject {
    enum GameState {
        case start
        case playing
        case gameOver
    }
    
    @Published var gameState: GameState = .start
    @Published var score: Int = 0
    @Published var timeLeft: Double = 10.0
    @Published var highScore: Int = 0
    @Published var buttonPosition: CGPoint = .zero
    @Published var comboMultiplier: Int = 1
    
    private var lastTapTime: Date = Date.distantPast
    private var gameTimer: Timer?
    private var movementTimer: Timer?
    
    private let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.highScore = UserDefaults.standard.integer(forKey: "highScore_tapFrenzy")
    }
    
    func startGame(playAreaSize: CGSize) {
        score = 0
        timeLeft = 10.0
        comboMultiplier = 1
        lastTapTime = Date.distantPast
        
        if playAreaSize != .zero {
            buttonPosition = CGPoint(x: playAreaSize.width / 2, y: playAreaSize.height / 2)
        }
        
        gameState = .playing
        initiateActiveTimers(playAreaSize: playAreaSize)
    }
    
    func executeTap(playAreaSize: CGSize) {
        guard timeLeft > 0 else { return }
        
        let contextTime = Date()
        if contextTime.timeIntervalSince(lastTapTime) < 0.5 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = contextTime
        
        score += (1 * comboMultiplier)
        
        // Move the button immediately when tapped to increase gameplay pace!
        relocateTargetPosition(playAreaSize: playAreaSize)
        
        // Reset movement timer interval so it stays at the new position for up to 2 seconds
        resetMovementTimer(playAreaSize: playAreaSize)
    }
    
    private func initiateActiveTimers(playAreaSize: CGSize) {
        invalidateRunningTimers()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeLeft > 0.05 {
                self.timeLeft -= 0.1
            } else {
                self.endActiveGameSession()
            }
        }
        
        resetMovementTimer(playAreaSize: playAreaSize)
    }
    
    private func resetMovementTimer(playAreaSize: CGSize) {
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.relocateTargetPosition(playAreaSize: playAreaSize)
        }
    }
    
    private func relocateTargetPosition(playAreaSize: CGSize) {
        guard gameState == .playing, playAreaSize.width > 120, playAreaSize.height > 260 else { return }
        
        let minXBoundary: CGFloat = 60
        let maxXBoundary: CGFloat = playAreaSize.width - 60
        let minYBoundary: CGFloat = 160
        let maxYBoundary: CGFloat = playAreaSize.height - 100
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            self.buttonPosition = CGPoint(
                x: CGFloat.random(in: minXBoundary...maxXBoundary),
                y: CGFloat.random(in: minYBoundary...maxYBoundary)
            )
        }
    }
    
    private func endActiveGameSession() {
        timeLeft = 0.0
        invalidateRunningTimers()
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore_tapFrenzy")
        }
        
        saveGameSession()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            gameState = .gameOver
        }
    }
    
    func invalidateRunningTimers() {
        gameTimer?.invalidate()
        movementTimer?.invalidate()
        gameTimer = nil
        movementTimer = nil
    }
    
    private func saveGameSession() {
        let lat = locationService.lastLocation?.coordinate.latitude ?? 0.0
        let lon = locationService.lastLocation?.coordinate.longitude ?? 0.0
        
        let newSession = GameSession(
            id: UUID(),
            mode: .tapFrenzy,
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
