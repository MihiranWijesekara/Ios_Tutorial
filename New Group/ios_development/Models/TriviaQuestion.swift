import Foundation

struct TriviaQuestion: Codable, Identifiable {
    var id = UUID()
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let difficulty: String   // "easy" | "medium" | "hard"

    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer   = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case difficulty
    }
}

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}
