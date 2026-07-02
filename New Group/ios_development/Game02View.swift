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
    @State private var showGameOver = false
    @State private var levelUpFlash = false
    
    // Timers
    @State private var gameTimer: Timer?
    @State private var flashTimer: Timer?
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header Stat Panel
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(score)").font(.title2).bold()
                        Text("Level: \(currentLevel.rawValue)").font(.subheadline).foregroundColor(currentLevel.glowColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Time: \(timeRemaining)s").font(.title2).bold()
                        Text("Lives: \(String(repeating: "❤️", count: lives))").font(.caption)
                    }
                }
                .padding(.horizontal)
                
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
                    .id(currentLevel) // Re-render grid when structure layout updates
                } else {
                    Button(action: startGame) {
                        Text("START GAME")
                            .font(.title3)
                            .bold()
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
                Color(currentLevel.glowColor)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // Game Over Summary Window
            if showGameOver {
                GameOverView(finalScore: score, isNewHigh: score > storedHighScore) {
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
        isPlaying = true
        generateCards()
        setupGameClock()
        setupFlashIntervalClock()
    }
    
    func generateCards() {
        cards = (0..<currentLevel.cardCount).map { _ in Card() }
        cycleLitCards()
    }
    
    // Global ticking down logic
    func setupGameClock() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard isPlaying else { return }
            
            if timeRemaining > 1 {
                timeRemaining -= 1
                checkLevelProgression()
            } else {
                timeRemaining = 0
                endGame()
            }
        }
    }
    
    // Handles shuffling positions based on speed variables
    func setupFlashIntervalClock() {
        flashTimer?.invalidate()
        flashTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litDuration, repeats: true) { _ in
            guard isPlaying else { return }
            cycleLitCards()
        }
    }
    
    // Tracks milestones along the 60-second runtime track
    func checkLevelProgression() {
        let elapsed = 60 - timeRemaining
        let calculatedLevel = GameLevel.getLevel(for: elapsed)
        
        if calculatedLevel != currentLevel {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentLevel = calculatedLevel
                levelUpFlash = true
            }
            generateCards()
            setupFlashIntervalClock() // Regenerate interval intervals
            
            // Automatically turn off flash notification overlay banner
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { levelUpFlash = false }
            }
        }
    }
    
    func cycleLitCards() {
        // Reset all active cards
        for i in 0..<cards.count { cards[i].isLit = false }
        
        // Randomly illuminate tiles matching configuration caps
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
    
    // Core Action Processing Logic
    func handleTap(on card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            score += 10
            cards[index].isLit = false // Clear state immediately on success
        } else {
            applyPenalty()
        }
    }
    
    func applyPenalty() {
        if lives > 1 {
            lives -= 1
        } else {
            lives = 0
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
