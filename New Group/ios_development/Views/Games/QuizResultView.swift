import SwiftUI

/// Simple end-of-game result screen shown after all 10 questions are answered.
struct QuizResultView: View {
    let score: Int
    let highScore: Int
    let correct: Int
    let wrong: Int
    let total: Int
    let onPlayAgain: () -> Void

    private var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * 100)
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // ── Trophy / emoji ──
                Text(percentage >= 70 ? "🎉" : "📝")
                    .font(.system(size: 64))

                Text(percentage >= 70 ? "Well Done!" : "Game Over")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                // ── Stats card ──
                VStack(spacing: 14) {
                    statRow(label: "Score",           value: "\(score)")
                    statRow(label: "High Score",      value: "\(highScore)")
                    Divider().background(Color.white.opacity(0.2))
                    statRow(label: "Correct",         value: "\(correct) / \(total)")
                    statRow(label: "Wrong",           value: "\(wrong)")
                    statRow(label: "Accuracy",        value: "\(percentage)%")
                }
                .padding()
                .background(Color.white.opacity(0.07))
                .cornerRadius(16)
                .padding(.horizontal)

                // ── Play Again button ──
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
            }
            .padding(.top, 40)
        }
    }

    @ViewBuilder
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
