import Foundation

// MARK: - ワイヤ形式（allcar-chat Worker / Durable Object と共通の JSON）

struct WireChatMessage: Codable {
    let id: String
    let sender: String       // "user-<id>"（サーバーが認証ユーザーから決定する）
    var senderName: String?  // 表示名
    var text: String?
    var carID: Int?
    var ts: Int?
}

/// サーバーから届くイベント。
/// - `history`: 接続直後に届く過去メッセージ（`messages`）
/// - `message`: リアルタイム配信（`message`）
struct ChatServerEvent: Decodable {
    let type: String
    var message: WireChatMessage?
    var messages: [WireChatMessage]?
}

/// 送信ペイロード。送信者はサーバーがセッショントークンから特定するため含めない。
private struct OutgoingChatMessage: Encodable {
    let type = "message"
    let id: String
    var text: String?
    var carID: Int?
}

// MARK: - WebSocket 接続

/// 1 部屋分の WebSocket 接続（README 7章: `URLSessionWebSocketTask`）。
/// 部屋（room）ごとに Durable Object が割り当てられる（README 8章）。
final class ChatSocket {

    /// allcar-chat Worker のエンドポイント
    static let wsBaseURL = URL(string: "wss://allcar-chat.nakamoto-allcar.workers.dev")!
    static let httpBaseURL = URL(string: "https://allcar-chat.nakamoto-allcar.workers.dev")!

    private var task: URLSessionWebSocketTask?
    private(set) var isConnected = false

    /// 受信イベント（MainActor 上で呼ばれる）
    var onEvent: (@MainActor (ChatServerEvent) -> Void)?

    /// 認証ユーザーのセッショントークンで部屋に接続する。
    func connect(roomID: String, token: String) {
        disconnect()
        var components = URLComponents(
            url: Self.wsBaseURL.appending(path: "api/chat/\(roomID)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        let task = URLSession.shared.webSocketTask(with: components.url!)
        self.task = task
        isConnected = true
        task.resume()
        listen(on: task)
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
    }

    func send(text: String? = nil, carID: Int? = nil) {
        guard let task else { return }
        let outgoing = OutgoingChatMessage(id: UUID().uuidString, text: text, carID: carID)
        guard let data = try? JSONEncoder().encode(outgoing),
              let json = String(data: data, encoding: .utf8) else { return }
        task.send(.string(json)) { [weak self] error in
            if error != nil {
                Task { @MainActor in self?.isConnected = false }
            }
        }
    }

    private func listen(on task: URLSessionWebSocketTask) {
        task.receive { [weak self] result in
            guard let self, self.task === task else { return }
            switch result {
            case .failure:
                Task { @MainActor in self.isConnected = false }
            case .success(let message):
                if case .string(let string) = message,
                   let data = string.data(using: .utf8),
                   let event = try? JSONDecoder().decode(ChatServerEvent.self, from: data) {
                    Task { @MainActor in self.onEvent?(event) }
                }
                self.listen(on: task)
            }
        }
    }
}
