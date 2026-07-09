import SwiftUI

/// The difficulty picker screen shown before starting a Quiz Rush game.
struct QuizDifficultyPickerView: View {
    @ObservedObject var viewModel: QuizRushVM

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.06, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // ── Title ──
                VStack(spacing: 8) {
                    Text("⚡ Quiz Rush")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Choose your difficulty")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 32)

                // ── Difficulty cards ──
                VStack(spacing: 16) {
                    ForEach(QuizDifficulty.allCases) { diff in
                        DifficultyCard(difficulty: diff) {
                            viewModel.setDifficulty(diff)
                            Task { await viewModel.loadGame() }
                        }
                    }
                }
                .padding(.horizontal, 24)

                // ── Legend ──
                VStack(spacing: 6) {
                    Text("Pass marks")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 20) {
                        legendItem("🟢 Easy",   "8 / 10")
                        legendItem("🟡 Medium", "7 / 10")
                        legendItem("🔴 Hard",   "6 / 10")
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func legendItem(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.75))
        }
    }
}

// ── Individual difficulty card ──
private struct DifficultyCard: View {
    let difficulty: QuizDifficulty
    let onTap: () -> Void

    @State private var pressed = false

    private var isLocked: Bool { !difficulty.isUnlocked }

    private var cardColors: [Color] {
        switch difficulty {
        case .easy:   return [Color(red: 0.1, green: 0.55, blue: 0.25), Color(red: 0.05, green: 0.4, blue: 0.18)]
        case .medium: return [Color(red: 0.65, green: 0.5, blue: 0.05), Color(red: 0.5, green: 0.35, blue: 0.02)]
        case .hard:   return [Color(red: 0.65, green: 0.1, blue: 0.15), Color(red: 0.5, green: 0.06, blue: 0.1)]
        }
    }

    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                pressed = false
                onTap()
            }
        }) {
            HStack(spacing: 20) {
                // Icon
                Text(isLocked ? "🔒" : difficulty.icon)
                    .font(.system(size: 36))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.title3.bold())
                        .foregroundColor(isLocked ? .white.opacity(0.35) : .white)

                    Text(isLocked
                         ? unlockHint
                         : "Pass mark: \(difficulty.passMarkCorrect) / 10 correct")
                        .font(.caption)
                        .foregroundColor(isLocked ? .white.opacity(0.25) : .white.opacity(0.75))
                }

                Spacer()

                // Chevron
                if !isLocked {
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.title2)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 22)
            .background(
                Group {
                    if isLocked {
                        Color.white.opacity(0.05)
                    } else {
                        LinearGradient(colors: cardColors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    }
                }
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isLocked
                            ? Color.white.opacity(0.08)
                            : Color.white.opacity(0.18),
                        lineWidth: 1
                    )
            )
            .scaleEffect(pressed ? 0.97 : 1.0)
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
    }

    private var unlockHint: String {
        guard let pre = difficulty.prerequisite else { return "" }
        return "Complete \(pre.displayName) first"
    }
}
