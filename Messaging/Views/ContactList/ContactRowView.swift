import SwiftUI

struct ContactRowView: View {
    let user: User
    var unreadCount: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            // Avatar + status dot
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(user.initials)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                StatusDotView(status: user.status, size: 12)
                    .offset(x: 2, y: 2)
            }

            // Name + status text
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(user.nickname)
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(user.uin)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Text(user.statusMessage.isEmpty ? user.status.label : user.statusMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Unread badge
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(ICQTheme.teal)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 5)
    }

    private var avatarColor: Color {
        let palette: [Color] = [.blue, .purple, .orange, .pink, .indigo, .teal, .cyan]
        return palette[abs(user.id.hashValue) % palette.count]
    }
}
