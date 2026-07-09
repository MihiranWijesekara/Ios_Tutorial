import Foundation

struct GameSession: Identifiable, Codable, Hashable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}
