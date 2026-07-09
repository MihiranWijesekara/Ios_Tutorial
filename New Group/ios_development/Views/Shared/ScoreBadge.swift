import SwiftUI

struct ScoreBadge: View {
    let score: Int
    let color: Color
    
    var body: some View {
        Text("\(score) pts")
            .font(.system(.body, design: .monospaced, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}
