import Foundation

class TriviaAPI {
    /// Fetches 10 multiple-choice trivia questions filtered by difficulty.
    func fetchQuestions(difficulty: QuizDifficulty) async throws -> [TriviaQuestion] {
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple&difficulty=\(difficulty.apiValue)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decoded.results
    }
}
