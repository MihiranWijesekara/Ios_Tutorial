import Foundation

/// The three difficulty tiers for Quiz Rush.
enum QuizDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    /// Value passed to the Open Trivia DB API.
    var apiValue: String { rawValue }

    /// Display name shown in the UI.
    var displayName: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }

    /// Emoji icon shown on the difficulty card.
    var icon: String {
        switch self {
        case .easy:   return "🟢"
        case .medium: return "🟡"
        case .hard:   return "🔴"
        }
    }

    /// Number of correct answers (out of 10) required to pass.
    var passMarkCorrect: Int {
        switch self {
        case .easy:   return 8
        case .medium: return 7
        case .hard:   return 6
        }
    }

    /// UserDefaults key storing whether this difficulty has been passed.
    var completedKey: String { "quizRush_completed_\(rawValue)" }

    /// UserDefaults key for the high score of this difficulty.
    var highScoreKey: String { "quizRush_highScore_\(rawValue)" }

    /// The difficulty that must be completed before this one is unlocked.
    var prerequisite: QuizDifficulty? {
        switch self {
        case .easy:   return nil
        case .medium: return .easy
        case .hard:   return .medium
        }
    }

    /// Whether the player may attempt this difficulty.
    var isUnlocked: Bool {
        guard let pre = prerequisite else { return true }
        return UserDefaults.standard.bool(forKey: pre.completedKey)
    }
}
