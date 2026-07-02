import Foundation

// The outer wrapper matching the "results" key
struct TriviaResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    // Unique ID for SwiftUI loops
    var id = UUID()
    
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    // Combine and shuffle correct + incorrect answers
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
    
    // Map JSON's snake_case to Swift's camelCase
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
