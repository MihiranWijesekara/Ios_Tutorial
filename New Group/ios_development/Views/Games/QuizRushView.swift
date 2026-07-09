import SwiftUI

struct QuizRushView: View {
    @ObservedObject var viewModel: QuizRushVM

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()

            gameplayInterface
        }
    }

    private var gameplayInterface: some View {
        VStack(spacing: 20) {
            // ── Header ──
            HStack {
                Text("Q \(viewModel.currentIndex + 1) / \(viewModel.totalQuestions)")
                Spacer()
                Text("🔥 \(viewModel.streak)")
                Spacer()
                Text("Score: \(viewModel.score)")
            }
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.top, 16)

            Spacer()

            // ── Question ──
            if let current = viewModel.currentQuestion {
                Text(current.question
                    .replacingOccurrences(of: "&amp;",  with: "&")
                    .replacingOccurrences(of: "&quot;", with: "\"")
                    .replacingOccurrences(of: "&#039;", with: "'")
                    .replacingOccurrences(of: "&lt;",   with: "<")
                    .replacingOccurrences(of: "&gt;",   with: ">"))
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // ── Answers ──
                VStack(spacing: 12) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        Button {
                            withAnimation { viewModel.handleAnswer(answer) }
                        } label: {
                            Text(answer
                                .replacingOccurrences(of: "&amp;",  with: "&")
                                .replacingOccurrences(of: "&quot;", with: "\"")
                                .replacingOccurrences(of: "&#039;", with: "'"))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}
