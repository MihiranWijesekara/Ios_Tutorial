//
//  CardTileModule.swift
//  ios_development
//
//  Created by student5 on 2026-07-02.
//

import SwiftUI

// Visual card block item
struct CardTile: View {
    let card: Card
    let level: GameLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 16)
                .fill(card.isLit ? level.glowColor : Color(.secondarySystemBackground))
                .aspectRatio(1.0, contentMode: .fit)
                .shadow(color: card.isLit ? level.glowColor.opacity(0.6) : .clear, radius: 10)
                .scaleEffect(card.isLit ? 1.04 : 1.0)
        }
        .buttonStyle(StaticTileButtonStyle())
    }
}

// Custom button wrapper to remove standard tap flash behavior
struct StaticTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// UI popover overlay window triggered when conditions match termination flags
struct GameOverView: View {
    let finalScore: Int
    let isNewHigh: Bool
    let actionRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("ROUND FINISHED")
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                
                if isNewHigh {
                    Text("🎉 NEW HIGH SCORE! 🎉")
                        .font(.headline)
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.0))
                }
                
                Text("\(finalScore)")
                    .font(.system(size: 64, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Button(action: actionRestart) {
                    Text("PLAY AGAIN")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 32)
            .background(Color(.darkGray))
            .cornerRadius(20)
            .padding(.horizontal, 36)
        }
    }
}

