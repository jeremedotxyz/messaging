import SwiftUI

/// Draws the classic ICQ daisy flower logo.
struct ICQFlowerView: View {
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            // 8 yellow petals
            ForEach(0..<8, id: \.self) { i in
                Ellipse()
                    .fill(ICQTheme.yellow)
                    .frame(width: size * 0.22, height: size * 0.44)
                    .offset(y: -(size * 0.18))
                    .rotationEffect(.degrees(Double(i) * 45))
            }
            // Teal center
            Circle()
                .fill(ICQTheme.teal)
                .frame(width: size * 0.36, height: size * 0.36)
            // White highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: -size * 0.04, y: -size * 0.04)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 24) {
        ForEach([24, 40, 64, 96] as [CGFloat], id: \.self) { s in
            ICQFlowerView(size: s)
        }
    }
    .padding()
    .background(ICQTheme.teal)
}
