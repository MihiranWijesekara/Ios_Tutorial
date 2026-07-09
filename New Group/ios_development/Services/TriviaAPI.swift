import Foundation

class TriviaAPI {
    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decodedResponse.results
    }
}
