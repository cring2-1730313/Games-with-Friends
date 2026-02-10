import SwiftUI

/// Individual clue tile component — rounded rectangle chip with icon, text, tier color
struct ClueChipView: View {
    let clue: Clue
    let isLatest: Bool

    var body: some View {
        HStack(spacing: 6) {
            // Order badge
            Text("\(clue.orderNumber)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(tierAccentColor)
                .clipShape(Circle())

            // Type icon
            Image(systemName: clue.type.icon)
                .font(.caption2)
                .foregroundStyle(tierAccentColor)

            // Clue text
            Text(clue.text)
                .font(.caption)
                .fontWeight(isLatest ? .semibold : .regular)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(clue.tier.color)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isLatest ? tierAccentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .opacity(isLatest ? 1.0 : 0.85)
        .shadow(color: isLatest ? tierAccentColor.opacity(0.3) : .clear, radius: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Clue \(clue.orderNumber): \(clue.text)")
    }

    var tierAccentColor: Color {
        switch clue.tier {
        case .vague: return .blue
        case .narrowing: return .green
        case .strongSignal: return .orange
        case .giveaway: return .red
        }
    }
}
