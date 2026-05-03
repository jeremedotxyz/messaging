import SwiftUI

struct ChatView: View {
    let contact: User
    @EnvironmentObject var store: ChatStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @FocusState private var inputFocused: Bool

    private var conversation: Conversation? {
        store.conversations.first { $0.contact.id == contact.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            messagesArea
            inputBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            if let id = conversation?.id { store.markRead(conversationId: id) }
        }
    }

    // MARK: – Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Text(contact.initials)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                StatusDotView(status: contact.status, size: 11)
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(contact.nickname)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(contact.statusMessage.isEmpty ? contact.status.label : contact.statusMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }

            Spacer()

            Text("UIN: \(contact.uin)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            LinearGradient(colors: [ICQTheme.teal, ICQTheme.tealDark],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    // MARK: – Messages

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 6) {
                    if let conv = conversation, !conv.messages.isEmpty {
                        ForEach(conv.messages) { msg in
                            MessageBubbleView(message: msg, isFromMe: msg.senderId == "me")
                                .id(msg.id)
                        }
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
            }
            .background(ICQTheme.background)
            .onAppear { scrollToBottom(proxy) }
            .onChange(of: conversation?.messages.count) { _ in scrollToBottom(proxy) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ICQFlowerView(size: 52)
            Text("Say hello to \(contact.nickname)!")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: – Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message \(contact.nickname)…", text: $text, axis: .vertical)
                .font(.system(size: 15))
                .lineLimit(1...6)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 0.75))
                .focused($inputFocused)

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(canSend ? ICQTheme.teal : Color(.systemGray4))
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Rectangle().fill(Color(.systemGray5)).frame(height: 0.5)
        }
    }

    // MARK: – Actions

    private var canSend: Bool { !text.trimmingCharacters(in: .whitespaces).isEmpty }

    private func send() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        text = ""
        store.send(to: contact.id, content: trimmed)

        // Simulate reply when not connected to a real server
        if !store.ws.isConnected {
            let delay = Double.random(in: 1.2...3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                store.receiveSimulated(from: contact.id)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = conversation?.messages.last else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }

    private var avatarColor: Color {
        let palette: [Color] = [.blue, .purple, .orange, .pink, .indigo, .teal, .cyan]
        return palette[abs(contact.id.hashValue) % palette.count]
    }
}
