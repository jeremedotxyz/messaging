import SwiftUI

struct StatusDotView: View {
    let status: UserStatus
    var size: CGFloat = 10

    @State private var pulse = false

    private var color: Color {
        switch status {
        case .online:  return ICQTheme.onlineGreen
        case .away:    return ICQTheme.awayYellow
        case .busy:    return ICQTheme.busyRed
        case .offline: return ICQTheme.offlineGray
        }
    }

    var body: some View {
        ZStack {
            if status == .online {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: size * 2, height: size * 2)
                    .scaleEffect(pulse ? 1.3 : 0.9)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }
            }
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1))
        }
    }
}
