import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isFromMe: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isFromMe { Spacer(minLength: 56) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 3) {
                Text(message.content)
                    .font(.system(size: 15))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(isFromMe ? ICQTheme.bubbleSent : Color(.systemBackground))
                    .foregroundStyle(Color.primary)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius:    isFromMe ? 16 : 4,
                            bottomLeadingRadius: isFromMe ? 16 : 16,
                            bottomTrailingRadius: isFromMe ? 4 : 16,
                            topTrailingRadius:   isFromMe ? 16 : 16
                        )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

                HStack(spacing: 4) {
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)

                    if isFromMe {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(message.isRead ? ICQTheme.teal : .secondary)
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isFromMe { Spacer(minLength: 56) }
        }
    }
}
