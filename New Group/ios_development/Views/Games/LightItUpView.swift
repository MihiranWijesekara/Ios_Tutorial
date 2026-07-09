import SwiftUI

struct LightItUpView: View {
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel: LightItUpVM
    
    init(locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: LightItUpVM(locationService: locationService))
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.13)
                .ignoresSafeArea()
            
            if viewModel.isPlaying && !viewModel.showVictoryModal && !viewModel.showGameOver && !viewModel.showLevelCompleteModal {
                gameplayInterface
            } else if viewModel.showVictoryModal {
                ResultView(
                    score: viewModel.score,
                    highScore: viewModel.storedHighScore,
                    gameMode: .lightItUp,
                    onPlayAgain: {
                        viewModel.startGame()
                    }
                )
            } else if viewModel.showGameOver {
                ResultView(
                    score: viewModel.score,
                    highScore: viewModel.storedHighScore,
                    gameMode: .lightItUp,
                    onPlayAgain: {
                        viewModel.startGame()
                    }
                )
            } else if viewModel.showLevelCompleteModal, let nextLevel = viewModel.currentLevel.next() {
                LevelCompleteModalView(completedLevel: viewModel.currentLevel, nextLevel: nextLevel) {
                    viewModel.advanceToNextLevel()
                }
            } else {
                startMenuView
            }
            
            if viewModel.levelUpFlash {
                viewModel.currentLevel.glowColor
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: viewModel.cleanUpTimers)
    }
    
    private var startMenuView: some View {
        VStack(spacing: 35) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("LIGHT IT UP")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Illumination sequence builder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if viewModel.storedHighScore > 0 {
                VStack(spacing: 6) {
                    Text("CURRENT HIGH SCORE")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.green)
                        .tracking(1.5)
                    Text("\(viewModel.storedHighScore) PTS")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
            }
            
            Spacer()
            
            Button(action: viewModel.startGame) {
                Text("START GAME")
                    .font(.title3).bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 220)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
    
    private var gameplayInterface: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Score: \(viewModel.score)")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text("Level: \(viewModel.currentLevel.rawValue)")
                        .font(.subheadline).bold()
                        .foregroundColor(viewModel.currentLevel.glowColor)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Time: \(viewModel.timeRemaining)s")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text("Lives: \(String(repeating: "❤️", count: viewModel.lives))")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
            
            ProgressView(value: min(Double(viewModel.score), Double(viewModel.currentLevel.targetScore)), total: Double(viewModel.currentLevel.targetScore))
                .progressViewStyle(LinearProgressViewStyle(tint: viewModel.currentLevel.glowColor))
                .padding(.horizontal)
            
            Text("Target to pass: \(viewModel.currentLevel.targetScore) pts")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Spacer()
            
            LazyVGrid(columns: viewModel.currentLevel.gridColumns, spacing: 16) {
                ForEach(viewModel.cards) { card in
                    CardTile(card: card, level: viewModel.currentLevel) {
                        viewModel.handleTap(on: card)
                    }
                }
            }
            .padding(24)
            .id(viewModel.currentLevel)
            
            Spacer()
        }
    }
}
