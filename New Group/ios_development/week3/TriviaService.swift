import Foundation

class TriviaService {
    func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            throw URLError(.badURL)
        }
        
        // Use async/await URLSession
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // FIX 1: Cleaned up the type casting syntax down below
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // FIX 2: Changed TriviaResponse.bind to TriviaResponse.self
        let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decodedResponse.results
    }
}
