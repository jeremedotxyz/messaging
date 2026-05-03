import Foundation
import Combine

class ChatStore: ObservableObject {
    @Published var currentUser: User
    @Published var contacts: [User]
    @Published var conversations: [Conversation]

    let ws = WebSocketService()
    private var bag = Set<AnyCancellable>()

    init() {
        currentUser = User(id: "me", uin: "12345678",
                           nickname: "You", statusMessage: "Hey there! I'm using ICQ",
                           status: .online)

        let all: [User] = [
            User(id: "1", uin: "11111111", nickname: "JohnDoe",  statusMessage: "At work 💼",       status: .online),
            User(id: "2", uin: "22222222", nickname: "Jane_S",   statusMessage: "brb",              status: .away),
            User(id: "3", uin: "33333333", nickname: "MikeC",    statusMessage: "do not disturb",   status: .busy),
            User(id: "4", uin: "44444444", nickname: "SaraP",    statusMessage: "I love ICQ! ☀️",   status: .online),
            User(id: "5", uin: "55555555", nickname: "Alex99",   statusMessage: "",                 status: .offline),
            User(id: "6", uin: "66666666", nickname: "TomK",     statusMessage: "On vacation 🏝",   status: .offline),
            User(id: "7", uin: "77777777", nickname: "LisaM",    statusMessage: "asl?",             status: .online),
        ]
        contacts = all

        conversations = [
            Conversation(id: "conv-1", contact: all[0], messages: [
                Message(senderId: "1",  content: "Hey! Long time no chat 😄", timestamp: .now - 3600, isRead: true),
                Message(senderId: "me", content: "I know, been super busy!", timestamp: .now - 3500, isRead: true),
                Message(senderId: "1",  content: "Remember when we used to chat all day on ICQ? 😂", timestamp: .now - 60,   isRead: false),
            ]),
            Conversation(id: "conv-4", contact: all[3], messages: [
                Message(senderId: "4",  content: "This app looks exactly like ICQ!! 😍", timestamp: .now - 7200, isRead: true),
                Message(senderId: "me", content: "Right?? Nostalgia 🌼",                 timestamp: .now - 7100, isRead: true),
            ]),
            Conversation(id: "conv-7", contact: all[6], messages: [
                Message(senderId: "7",  content: "asl?", timestamp: .now - 86400, isRead: true),
                Message(senderId: "me", content: "lol classic 😂", timestamp: .now - 86300, isRead: true),
            ]),
        ]

        ws.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)

        ws.inbound
            .sink { [weak self] env in self?.handle(env) }
            .store(in: &bag)
    }

    // MARK: – Public API

    func send(to contactId: String, content: String) {
        let msg = Message(senderId: "me", content: content, isRead: true)
        upsert(message: msg, in: contactId)
        if ws.isConnected {
            ws.sendChat(from: currentUser.id, to: contactId, content: content)
        }
    }

    func receiveSimulated(from contactId: String) {
        let lines = ["lol 😂", "haha yeah!", "brb", "omg no way 😲", "true!", "same lol",
                     "wait really?", "ok cool", "gtg, ttyl! 👋", "💯", "uh oh! 🌼"]
        let msg = Message(senderId: contactId, content: lines.randomElement()!)
        upsert(message: msg, in: contactId)
    }

    func startConversation(with contact: User) {
        guard !conversations.contains(where: { $0.contact.id == contact.id }) else { return }
        conversations.insert(Conversation(id: UUID().uuidString, contact: contact, messages: []), at: 0)
    }

    func markRead(conversationId: String) {
        guard let i = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        for j in conversations[i].messages.indices { conversations[i].messages[j].isRead = true }
    }

    func setStatus(_ status: UserStatus) {
        currentUser.status = status
        if ws.isConnected { ws.sendStatus(status, userId: currentUser.id) }
    }

    func connectWS(serverURL: String) {
        guard let url = URL(string: serverURL) else { return }
        ws.connect(to: url)
    }

    // MARK: – Private

    private func upsert(message: Message, in contactId: String) {
        if let i = conversations.firstIndex(where: { $0.contact.id == contactId }) {
            conversations[i].messages.append(message)
        } else if let contact = contacts.first(where: { $0.id == contactId }) {
            conversations.insert(Conversation(id: UUID().uuidString, contact: contact, messages: [message]), at: 0)
        }
    }

    private func handle(_ env: WSEnvelope) {
        switch env.type {
        case "chat":
            guard let from = env.senderId, let text = env.content else { return }
            upsert(message: Message(senderId: from, content: text), in: from)
        case "status":
            guard let uid = env.userId, let status = env.status else { return }
            if let i = contacts.firstIndex(where: { $0.id == uid }) { contacts[i].status = status }
        default: break
        }
    }
}
