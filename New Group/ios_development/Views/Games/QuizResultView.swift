import SwiftUI

/// End-of-game result screen shown after all 10 questions are answered.
struct QuizResultView: View {
    let score: Int
    let highScore: Int
    let correct: Int
    let wrong: Int
    let total: Int
    let difficulty: QuizDifficulty
    let passed: Bool
    let onPlayAgain: () -> Void
    let onChangeDifficulty: () -> Void

    private var percentage: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * 100)
    }

    // Next difficulty unlocked by passing this one
    private var nextDifficulty: QuizDifficulty? {
        switch difficulty {
        case .easy:   return .medium
        case .medium: return .hard
        case .hard:   return nil
        }
    }

    var body: some View {
        ZStack {
            // ── Background ──
            LinearGradient(
                colors: passed
                    ? [Color(red: 0.05, green: 0.15, blue: 0.08), Color(red: 0.04, green: 0.08, blue: 0.04)]
                    : [Color(red: 0.12, green: 0.04, blue: 0.04), Color(red: 0.05, green: 0.05, blue: 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // ── Result banner ──
                    VStack(spacing: 10) {
                        Text(passed ? "🎉" : "😔")
                            .font(.system(size: 64))

                        Text(passed ? "You Passed!" : "Not Quite…")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        // Difficulty badge
                        HStack(spacing: 6) {
                            Text(difficulty.icon)
                            Text(difficulty.displayName)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(20)
                        .foregroundColor(.white.opacity(0.85))
                    }

                    // ── Pass mark indicator ──
                    passMarkBar

                    // ── Stats card ──
                    VStack(spacing: 14) {
                        statRow(label: "Score",      value: "\(score)")
                        statRow(label: "High Score", value: "\(highScore)")
                        Divider().background(Color.white.opacity(0.2))
                        statRow(label: "Correct",    value: "\(correct) / \(total)")
                        statRow(label: "Wrong",      value: "\(wrong)")
                        statRow(label: "Accuracy",   value: "\(percentage)%")
                        statRow(label: "Pass Mark",  value: "\(difficulty.passMarkCorrect) / \(total) correct")
                    }
                    .padding()
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // ── Unlock banner ──
                    if passed, let next = nextDifficulty {
                        unlockBanner(for: next)
                    }

                    // ── Action buttons ──
                    VStack(spacing: 12) {
                        // Play Again (same difficulty)
                        Button(action: onPlayAgain) {
                            Label("Play Again", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    passed
                                    ? LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 32)

                        // Change difficulty
                        Button(action: onChangeDifficulty) {
                            Label("Change Difficulty", systemImage: "list.bullet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.65))
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 40)
            }
        }
    }

    // ── Pass-mark progress bar ──
    private var passMarkBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)

                    // Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            passed
                            ? LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * min(Double(correct) / Double(total), 1.0), height: 12)

                    // Pass-mark line
                    let passX = geo.size.width * (Double(difficulty.passMarkCorrect) / Double(total))
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 20)
                        .offset(x: passX - 1, y: -4)
                }
            }
            .frame(height: 12)
            .padding(.horizontal)

            HStack {
                Text("\(correct) correct")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("Need \(difficulty.passMarkCorrect)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal)
        }
    }

    // ── Unlock banner ──
    private func unlockBanner(for next: QuizDifficulty) -> some View {
        HStack(spacing: 12) {
            Text("🔓")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(next.displayName) Unlocked!")
                    .font(.subheadline.bold())
                    .foregroundColor(.yellow)
                Text("You can now play \(next.displayName) mode.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(14)
        .padding(.horizontal)
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
