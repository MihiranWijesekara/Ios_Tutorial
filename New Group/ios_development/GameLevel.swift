//
//  GameLevel.swift
//  ios_development
//
//  Created by student5 on 2026-07-04.
//

import SwiftUI

enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    // Points target required to finish the current level
    var targetScore: Int {
        switch self {
        case .L1: return 50
        case .L2: return 120
        case .L3: return 200
        case .L4: return 300 // Final win condition milestone
        }
    }
    
    // Number of total cards shown in the grid
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    // Dynamic columns matching assignment specs
    var gridColumns: [GridItem] {
        switch self {
        case .L1:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 cards single row
        case .L2, .L3:
            return [GridItem(.flexible()), GridItem(.flexible())] // 2 columns layout
        case .L4:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3x3 grid layout
        }
    }
    
    // How long a card stays lit (seconds)
    var litDuration: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    // Number of cards to ignite simultaneously
    var simultaneousLitCount: Int {
        return self == .L4 ? 2 : 1
    }
    
    // Distinct glow colors per level
    var glowColor: Color {
        switch self {
        case .L1: return .green
        case .L2: return .blue
        case .L3: return .orange
        case .L4: return .purple
        }
    }
    
    // Helper to advance sequence manually
    func next() -> GameLevel? {
        return GameLevel(rawValue: self.rawValue + 1)
    }
}
