import SwiftUI

enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    var targetScore: Int {
        switch self {
        case .L1: return 50
        case .L2: return 120
        case .L3: return 200
        case .L4: return 300
        }
    }
    
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    var gridColumns: [GridItem] {
        switch self {
        case .L1:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        case .L2, .L3:
            return [GridItem(.flexible()), GridItem(.flexible())]
        case .L4:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }
    
    var litDuration: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    var simultaneousLitCount: Int {
        return self == .L4 ? 2 : 1
    }
    
    var glowColor: Color {
        switch self {
        case .L1: return .green
        case .L2: return .blue
        case .L3: return .orange
        case .L4: return .purple
        }
    }
    
    func next() -> GameLevel? {
        return GameLevel(rawValue: self.rawValue + 1)
    }
}
