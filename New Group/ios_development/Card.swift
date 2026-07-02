//
//  Card.swift
//  ios_development
//
//  Created by student5 on 2026-07-02.
//

import SwiftUI

// Struct modeling a single card in the grid
struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

// Enum defining level progression parameters
enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    // Determine level by seconds elapsed
    static func getLevel(for secondsElapsed: Int) -> GameLevel {
        switch secondsElapsed {
        case 0..<15:   return .L1   // 0-15s
        case 15..<30:  return .L2   // 15-30s
        case 30..<45:  return .L3   // 30-45s
        default:       return .L4   // 45s to end
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
    
    // Dynamic columns for LazyVGrid layout
    var gridColumns: [GridItem] {
        switch self {
        case .L1, .L2:
            return [GridItem(.flexible()), GridItem(.flexible())]
        case .L3, .L4:
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
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
    
    // Bonus Feature: Distinct glow colors per level
    var glowColor: Color {
        switch self {
        case .L1: return .green
        case .L2: return .blue
        case .L3: return .orange
        case .L4: return .purple
        }
    }
}

