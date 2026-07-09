import SwiftUI

struct TapFrenzyView: View {
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel: TapFrenzyVM
    
    init(locationService: LocationService) {
        _viewModel = StateObject(wrappedValue: TapFrenzyVM(locationService: locationService))
    }
    
    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .start:
                startMenuView
            case .playing:
                gamePlayView
            case .gameOver:
                ResultView(
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    gameMode: .tapFrenzy,
                    onPlayAgain: {
                        viewModel.gameState = .start
                    }
                )
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            viewModel.invalidateRunningTimers()
        }
    }
    
    private var startMenuView: some View {
        VStack(spacing: 35) {
            Spacer()
            
            VStack(spacing: 10) {
                Text("TAP FRENZY")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.white)
                
                Text("Test your response times")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if viewModel.highScore > 0 {
                VStack(spacing: 6) {
                    Text("CURRENT HIGH SCORE")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange.opacity(0.8))
                        .tracking(1.5)
                    Text("\(viewModel.highScore) PTS")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.04))
                .cornerRadius(16)
            }
            
            Spacer()
            
            GeometryReader { proxy in
                Button(action: {
                    viewModel.startGame(playAreaSize: proxy.size)
                }) {
                    Text("START BLITZ")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .cornerRadius(14)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea())
    }
    
    private var gamePlayView: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            Text("\(viewModel.score)")
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if viewModel.comboMultiplier > 1 {
                            Text("x\(viewModel.comboMultiplier)")
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME REMAINING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            Text(String(format: "%.1fs", viewModel.timeLeft))
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(viewModel.timeLeft <= 3.0 ? .red : .white)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                
                Button(action: {
                    viewModel.executeTap(playAreaSize: proxy.size)
                }) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 100, height: 100)
                        .scaleEffect(max(0.45, viewModel.timeLeft / 10.0))
                }
                .position(viewModel.buttonPosition)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.buttonPosition)
            }
            .onAppear {
                if viewModel.buttonPosition == .zero {
                    viewModel.buttonPosition = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
            }
        }
        .padding()
        .background(Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea())
    }
}
