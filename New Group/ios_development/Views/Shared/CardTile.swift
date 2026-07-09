import SwiftUI

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

struct StaticTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
