import Foundation

struct Conversation: Identifiable {
    let id: String
    let contact: User
    var messages: [Message]

    var lastMessage: Message? { messages.last }
    var unreadCount: Int { messages.filter { !$0.isRead && $0.senderId != "me" }.count }
}
