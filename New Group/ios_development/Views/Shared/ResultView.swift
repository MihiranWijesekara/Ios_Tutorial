import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let gameMode: GameMode
    let onPlayAgain: () -> Void
    
    var shareString: String {
        "I just scored \(score) on \(gameMode.rawValue) in PlayHub! Can you beat that?"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: gameMode.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("ROUND COMPLETED")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(gameMode.rawValue)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Text("Your Score")
                        .foregroundColor(.gray)
                    Spacer()
                    ScoreBadge(score: score, color: .orange)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Text("High Score")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(highScore) pts")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .background(Color.white.opacity(0.04))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            
            ShareLink(item: shareString) {
                Label("Share Your Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: onPlayAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("PLAY AGAIN")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(14)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.03, green: 0.03, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
