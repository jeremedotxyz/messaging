import Foundation

enum UserStatus: String, Codable, CaseIterable {
    case online, away, busy, offline

    var label: String {
        switch self {
        case .online:  return "Online"
        case .away:    return "Away"
        case .busy:    return "Do Not Disturb"
        case .offline: return "Offline"
        }
    }

    var sortOrder: Int {
        switch self {
        case .online: return 0; case .away: return 1
        case .busy:   return 2; case .offline: return 3
        }
    }
}

struct User: Identifiable, Codable {
    let id: String
    var uin: String
    var nickname: String
    var statusMessage: String
    var status: UserStatus

    var initials: String { String(nickname.prefix(2)).uppercased() }
}
