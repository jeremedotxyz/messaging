import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    var isRead: Bool

    init(id: String = UUID().uuidString,
         senderId: String,
         content: String,
         timestamp: Date = .now,
         isRead: Bool = false) {
        self.id        = id
        self.senderId  = senderId
        self.content   = content
        self.timestamp = timestamp
        self.isRead    = isRead
    }
}
