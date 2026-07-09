import SwiftUI

struct LevelCompleteModalView: View {
    let completedLevel: GameLevel
    let nextLevel: GameLevel
    let actionNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("LEVEL COMPLETE")
                    .font(.system(.title, design: .rounded)).bold()
                    .foregroundColor(completedLevel.glowColor)
                
                Text("You have successfully passed Level \(completedLevel.rawValue)!")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Get ready for Level \(nextLevel.rawValue)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Button(action: actionNext) {
                    Text("START LEVEL \(nextLevel.rawValue)")
                        .font(.callout).bold()
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(nextLevel.glowColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 32)
            .background(Color(red: 0.15, green: 0.17, blue: 0.2))
            .cornerRadius(20)
            .padding(.horizontal, 36)
        }
    }
}

struct GameVictoryModalView: View {
    let finalScore: Int
    let isNewHigh: Bool
    let actionRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🏆 VICTORY! 🏆")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .foregroundColor(.yellow)
                
                Text("You completed all game levels!")
                    .font(.body)
                    .foregroundColor(.white)
                
                if isNewHigh {
                    Text("🎉 NEW HIGH SCORE! 🎉")
                        .font(.headline)
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                }
                
                Text("\(finalScore)")
                    .font(.system(size: 64, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Button(action: actionRestart) {
                    Text("PLAY AGAIN")
                        .font(.callout).bold()
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 32)
            .background(Color(red: 0.12, green: 0.14, blue: 0.16))
            .cornerRadius(20)
            .padding(.horizontal, 36)
        }
    }
}

struct GameOverView: View {
    let finalScore: Int
    let isNewHigh: Bool
    let reason: String
    let actionRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("GAME OVER")
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(.red)
                
                Text(reason)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if isNewHigh {
                    Text("🎉 NEW HIGH SCORE! 🎉")
                        .font(.headline)
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                }
                
                Text("\(finalScore)")
                    .font(.system(size: 64, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Button(action: actionRestart) {
                    Text("TRY AGAIN")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 32)
            .background(Color(.darkGray))
            .cornerRadius(20)
            .padding(.horizontal, 36)
        }
    }
}
