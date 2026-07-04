
import SwiftUI

enum GameState {
    case start
    case playing
    case gameOver
}

struct ContentView: View {
    // Core Game State
    @State private var gameState: GameState = .start
    @State private var score: Int = 0
    @State private var timeLeft: Double = 10.0
    @State private var highScore: Int = 0
    
    // Challenge System States
    @State private var buttonPosition: CGPoint = .zero
    @State private var comboMultiplier: Int = 1
    @State private var lastTapTime: Date = Date.distantPast
    
    // Screen Tracking for Random Targets
    @State private var playAreaSize: CGSize = .zero
    
    // Core Timers
    @State private var gameTimer: Timer?
    @State private var movementTimer: Timer?
    
    var body: some View {
        ZStack {
            // Premium Dark Background Gradient
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.03, green: 0.03, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background Decorative Elements for Visual Depth
            Circle()
                .fill(Color.orange.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.05))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 100, y: 300)
            
            // State-driven View Architecture
            VStack {
                switch gameState {
                case .start:
                    startMenuView
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
                    
                case .playing:
                    gamePlayView
                        .transition(.opacity)
                    
                case .gameOver:
                    gameOverView
                        .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 1.05)), removal: .opacity))
                }
            }
            .padding()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: gameState)
    }

    private var startMenuView: some View {
        VStack(spacing: 35) {
            Spacer()
            
            // Branding Header
            VStack(spacing: 10) {
                Text("TAP FRENZY")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.init(hex: "FFE000"), .init(hex: "799F0C")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("BSC (HONS) COMPUTING")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.gray.opacity(0.8))
            }
            
            // High Score Board (Glassmorphism card)
            if highScore > 0 {
                VStack(spacing: 6) {
                    Text("CURRENT HIGH SCORE")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange.opacity(0.8))
                        .tracking(1.5)
                    Text("\(highScore) PTS")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Action Start Button
            Button(action: startGame) {
                Text("START BLITZ")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.init(hex: "FFE000"), .init(hex: "799F0C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .init(hex: "FFE000").opacity(0.3), radius: 15, y: 5)
            }
            .padding(.horizontal, 20)
        }
    }

    private var gamePlayView: some View {
        GeometryReader { proxy in
            ZStack {
                // Top Dashboard HUD
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        // Score Module
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(.gray)
                            Text("\(score)")
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Combo Multiplier Module (Challenge 1)
                        if comboMultiplier > 1 {
                            VStack(alignment: .center, spacing: 4) {
                                Text("COMBO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.orange)
                                Text("x\(comboMultiplier)")
                                    .font(.system(size: 22, weight: .heavy))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        // Digital Precision Timer Module
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME REMAINING")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(.gray)
                            Text(String(format: "%.1fs", timeLeft))
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(timeLeft <= 3.0 ? .red : .white)
                                .scaleEffect(timeLeft <= 3.0 ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: timeLeft)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                // Interactive Play Canvas Area
                Button(action: executeTap) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.init(hex: "FFE000"), .init(hex: "799F0C")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .init(hex: "FFE000").opacity(0.4), radius: 12)
                        // CHALLENGE 4: Progressively scales button down down to min 45% size as time winds down
                        .scaleEffect(max(0.45, timeLeft / 10.0))
                }
                .position(buttonPosition)
                // CHALLENGE 3: Custom smooth physical animation tracking position shifts
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: buttonPosition)
            }
            .onAppear {
                playAreaSize = proxy.size
                // Position button safely centered on startup
                if buttonPosition == .zero {
                    buttonPosition = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
                initiateActiveTimers()
            }
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Finish Hex Icon Status
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 90, height: 90)
                Image(systemName: "timer")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("BLITZ COMPLETED")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(.white)
                Text("Great operational execution.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Score Grid Displays
            VStack(spacing: 16) {
                HStack {
                    Text("Your Score")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(score) pts")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Text("All-Time High Score")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(highScore) pts")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundColor(score >= highScore && score > 0 ? .green : .white)
                }
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            
            Spacer()
            
            // Clean Reset/Restart Button
            Button(action: startGame) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("PLAY AGAIN")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .white.opacity(0.15), radius: 10, y: 4)
            }
        }
    }

    
    private var minXBoundary: CGFloat { 60 }
    private var maxXBoundary: CGFloat { playAreaSize.width - 60 }
    private var minYBoundary: CGFloat { 160 }
    private var maxYBoundary: CGFloat { playAreaSize.height - 100 }
    
    private func startGame() {
        score = 0
        timeLeft = 10.0
        comboMultiplier = 1
        lastTapTime = Date.distantPast
        
        // Initial center layout config safely before update fires
        if playAreaSize != .zero {
            buttonPosition = CGPoint(x: playAreaSize.width / 2, y: playAreaSize.height / 2)
        }
        
        gameState = .playing
    }
    
    private func executeTap() {
        guard timeLeft > 0 else { return }
        
        let contextTime = Date()
        // CHALLENGE 1: Combo Engine Evaluation Loop (< 0.5 seconds window)
        if contextTime.timeIntervalSince(lastTapTime) < 0.5 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = contextTime
        
        score += (1 * comboMultiplier)
    }
    
    private func initiateActiveTimers() {
        invalidateRunningTimers()
        
        // High Precision Refresh Engine (Updates UI clocks every 0.1s smoothly)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.timeLeft > 0.05 {
                self.timeLeft -= 0.1
            } else {
                self.endActiveGameSession()
            }
        }
        
        // CHALLENGE 3: Positional Relocation Engine (Executes every 2.0s with explicit spec accuracy)
        movementTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            relocateTargetPosition()
        }
    }
    
    private func relocateTargetPosition() {
        guard gameState == .playing, playAreaSize.width > 120, playAreaSize.height > 260 else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            buttonPosition = CGPoint(
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
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            gameState = .gameOver
        }
    }
    
    private func invalidateRunningTimers() {
        gameTimer?.invalidate()
        movementTimer?.invalidate()
        gameTimer = nil
        movementTimer = nil
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
