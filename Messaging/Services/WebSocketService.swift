import Foundation
import Combine

struct WSEnvelope: Codable {
    let type: String
    let senderId: String?
    let recipientId: String?
    let content: String?
    let status: UserStatus?
    let userId: String?
}

class WebSocketService: ObservableObject {
    @Published var isConnected = false

    let inbound = PassthroughSubject<WSEnvelope, Never>()

    private var task: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)

    func connect(to url: URL) {
        task = session.webSocketTask(with: url)
        task?.resume()
        listen()
        task?.sendPing { [weak self] error in
            DispatchQueue.main.async {
                self?.isConnected = error == nil
            }
        }
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }

    func sendChat(from senderId: String, to recipientId: String, content: String) {
        let env = WSEnvelope(type: "chat", senderId: senderId,
                             recipientId: recipientId, content: content,
                             status: nil, userId: nil)
        guard let data = try? JSONEncoder().encode(env),
              let str  = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    func sendStatus(_ status: UserStatus, userId: String) {
        let env = WSEnvelope(type: "status", senderId: nil, recipientId: nil,
                             content: nil, status: status, userId: userId)
        guard let data = try? JSONEncoder().encode(env),
              let str  = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    private func listen() {
        task?.receive { [weak self] result in
            switch result {
            case .success(let msg):
                let data: Data?
                switch msg {
                case .string(let s): data = s.data(using: .utf8)
                case .data(let d):   data = d
                @unknown default:    data = nil
                }
                if let data, let env = try? JSONDecoder().decode(WSEnvelope.self, from: data) {
                    DispatchQueue.main.async { self?.inbound.send(env) }
                }
                self?.listen()
            case .failure:
                DispatchQueue.main.async { self?.isConnected = false }
            }
        }
    }
}
