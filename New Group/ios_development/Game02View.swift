import SwiftUI

struct LightItUpView: View {
    @AppStorage("highScore_lightItUp") private var storedHighScore = 0
    
    // Core game state markers
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeRemaining = 60
    @State private var currentLevel: GameLevel = .L1
    @State private var isPlaying = false
    
    // Modals Control Triggers
    @State private var showGameOver = false
    @State private var gameOverReason = ""
    @State private var showLevelCompleteModal = false
    @State private var showVictoryModal = false
    @State private var levelUpFlash = false
    
    // Timers
    @State private var gameTimer: Timer?
    @State private var flashTimer: Timer?
    
    var body: some View {
        ZStack {
            // Setup assignment themed background color canvas
            Color(red: 0.08, green: 0.11, blue: 0.13)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Stat Panel
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(score)")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                        Text("Level: \(currentLevel.rawValue)")
                            .font(.subheadline).bold()
                            .foregroundColor(currentLevel.glowColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Time: \(timeRemaining)s")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                        Text("Lives: \(String(repeating: "❤️", count: lives))")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // Progress tracker indicator bar
                ProgressView(value: min(Double(score), Double(currentLevel.targetScore)), total: Double(currentLevel.targetScore))
                    .progressViewStyle(LinearProgressViewStyle(tint: currentLevel.glowColor))
                    .padding(.horizontal)
                Text("Target to pass: \(currentLevel.targetScore) pts")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Core Interactivity Grid
                if isPlaying {
                    LazyVGrid(columns: currentLevel.gridColumns, spacing: 16) {
                        ForEach(cards) { card in
                            CardTile(card: card, level: currentLevel) {
                                handleTap(on: card)
                            }
                        }
                    }
                    .padding(24)
                    .id(currentLevel) // Re-render grid layout structures properly when changes occur
                } else {
                    Button(action: startGame) {
                        Text("START GAME")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            
            // Level Up Flash Overlay Notification
            if levelUpFlash {
                currentLevel.glowColor
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // POPUP OVERLAY WINDOW 1: Level Completed Interstitial Break
            if showLevelCompleteModal, let nextLevel = currentLevel.next() {
                LevelCompleteModalView(completedLevel: currentLevel, nextLevel: nextLevel) {
                    advanceToNextLevel()
                }
            }
            
            // POPUP OVERLAY WINDOW 2: Total Game Won Completion Clear
            if showVictoryModal {
                GameVictoryModalView(finalScore: score, isNewHigh: score > storedHighScore) {
                    resetAndRestart()
                }
            }
            
            // POPUP OVERLAY WINDOW 3: Game Over Failure Screen
            if showGameOver {
                GameOverView(finalScore: score, isNewHigh: score > storedHighScore, reason: gameOverReason) {
                    resetAndRestart()
                }
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: cleanUpTimers)
    }
    
    // Initialization setup
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
    
    // Global clock ticking down logic
    func setupGameClock() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard isPlaying && !showLevelCompleteModal && !showVictoryModal && !showGameOver else { return }
            
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timeRemaining = 0
                gameOverReason = "Out of Time!"
                endGame()
            }
        }
    }
    
    // Handles shuffling active card selections
    func setupFlashIntervalClock() {
        flashTimer?.invalidate()
        flashTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litDuration, repeats: true) { _ in
            guard isPlaying && !showLevelCompleteModal && !showVictoryModal && !showGameOver else { return }
            cycleLitCards()
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
                cards[index].isLit = true
            }
        }
    }
    
    // Core Action Click processing
    func handleTap(on card: Card) {
        // Guard against clicking when modals are actively displayed
        guard !showLevelCompleteModal && !showVictoryModal && !showGameOver else { return }
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            score += 10
            cards[index].isLit = false
            checkScoreProgression() // Check if score passed level thresholds
        } else {
            applyPenalty()
        }
    }
    
    // Evaluates score against the current level target milestone requirements
    func checkScoreProgression() {
        if score >= currentLevel.targetScore {
            // Check if there is an upcoming level, otherwise trigger global victory
            if let _ = currentLevel.next() {
                pauseGameForModal()
                withAnimation {
                    showLevelCompleteModal = true
                }
            } else {
                // No higher levels exist: Game Completed!
                pauseGameForModal()
                withAnimation {
                    showVictoryModal = true
                }
            }
        }
    }
    
    // Clears the board temporarily and suspends clocks safely
    func pauseGameForModal() {
        for i in 0..<cards.count { cards[i].isLit = false }
        cleanUpTimers()
    }
    
    // Progression execution called by clicking the Next Button on the modal view
    func advanceToNextLevel() {
        if let nextLevel = currentLevel.next() {
            currentLevel = nextLevel
            showLevelCompleteModal = false
            
            // Flash notification screen sequence overlay
            withAnimation(.easeInOut(duration: 0.2)) {
                levelUpFlash = true
            }
            
            generateCards()
            setupGameClock()
            setupFlashIntervalClock()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { levelUpFlash = false }
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
        }
        withAnimation { showGameOver = true }
    }
    
    func resetAndRestart() {
        showGameOver = false
        showVictoryModal = false
        showLevelCompleteModal = false
        startGame()
    }
    
    func cleanUpTimers() {
        gameTimer?.invalidate()
        flashTimer?.invalidate()
        gameTimer = nil
        flashTimer = nil
    }
}

#Preview {
    LightItUpView()
}
