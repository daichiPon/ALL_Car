import Foundation
import Observation

/// アプリ全体で共有する状態。
/// お気に入り・コメント・トークを保持する。バックエンド接続後は
/// `CarRepository` / `ChatSocket` と同期させる。
@Observable
final class AppStore {

    // MARK: 依存

    let repository: CarRepository

    // MARK: 車

    private(set) var cars: [Car] = []
    private(set) var news: [NewsItem] = []
    private(set) var featured: [Car] = []

    // MARK: お気に入り

    private(set) var favoriteIDs: Set<Int> = []

    // MARK: コメント（車 ID ごと）

    private(set) var comments: [Int: [CommentItem]] = [:]

    // MARK: トーク

    var friends: [Friend] = []
    private(set) var chats: [UUID: [ChatMessage]] = [:]

    // MARK: ユーザー（認証）

    private(set) var currentUser: UserAccount?

    /// タブ切り替え用（車をシェアしたあとトークへ飛ばす）
    var selectedTab: RootTab = .home

    private let favoritesKey = "allcar.favorites"

    init(repository: CarRepository = APICarRepository()) {
        self.repository = repository
        self.favoriteIDs = Self.loadFavorites(key: favoritesKey)
        self.comments = MockData.comments
        resetMockFriends()
    }

    /// 未ログイン時のローカルデモ用の友達・チャット。
    private func resetMockFriends() {
        friends = MockData.friends
        chats = [:]
        for friend in friends {
            chats[friend.id] = MockData.initialChat(for: friend)
        }
    }

    // MARK: - 読み込み

    func load() async {
        async let cars = repository.cars(maker: nil, model: nil, transType: nil)
        async let news = repository.news()
        async let featured = repository.featuredCars()
        self.cars = (try? await cars) ?? []
        self.news = (try? await news) ?? []
        self.featured = (try? await featured) ?? []
        self.currentUser = try? await AuthService.restoreSession()
        if currentUser != nil {
            await loadFriends()
        }
    }

    // MARK: - 認証

    func register(name: String, email: String, password: String) async throws {
        currentUser = try await AuthService.register(name: name, email: email, password: password)
        await loadFriends()
    }

    func login(email: String, password: String) async throws {
        currentUser = try await AuthService.login(email: email, password: password)
        await loadFriends()
    }

    func logout() {
        closeChat()
        AuthService.logout()
        currentUser = nil
        resetMockFriends()
    }

    // MARK: - 友達（README フェーズ3: friendships）

    /// ログイン中は D1 の friendships から友達を取得する。
    func loadFriends() async {
        guard currentUser != nil, let token = AuthService.token else {
            resetMockFriends()
            return
        }
        struct FriendDTO: Decodable {
            let id: Int
            let name: String
            let email: String
        }
        var request = URLRequest(url: APICarRepository.baseURL.appending(path: "api/friends"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let dtos = try? JSONDecoder().decode([FriendDTO].self, from: data) else { return }
        friends = dtos.map {
            Friend(name: $0.name, last: "トークをはじめよう", unread: 0, active: true, userID: $0.id)
        }
        // 実友達の履歴はサーバー（Durable Object）が正
        chats = [:]
    }

    /// メールアドレスで友達を追加する（相手も登録済みユーザーである必要がある）。
    func addFriend(email: String) async throws {
        guard let token = AuthService.token else {
            throw AuthError.server("友達を追加するにはログインしてください")
        }
        var request = URLRequest(url: APICarRepository.baseURL.appending(path: "api/friends"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(["email": email])
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            struct ErrorResponse: Decodable { let error: String }
            let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error
            throw AuthError.server(message ?? "通信エラー (\(status))")
        }
        await loadFriends()
    }

    func car(id: Int) -> Car? {
        cars.first { $0.id == id } ?? MockData.cars.first { $0.id == id }
    }

    // MARK: - お気に入り

    func isFavorite(_ car: Car) -> Bool {
        favoriteIDs.contains(car.id)
    }

    func toggleFavorite(_ car: Car) {
        if favoriteIDs.contains(car.id) {
            favoriteIDs.remove(car.id)
        } else {
            favoriteIDs.insert(car.id)
        }
        saveFavorites()
    }

    var favoriteCars: [Car] {
        cars.filter { favoriteIDs.contains($0.id) }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }

    private static func loadFavorites(key: String) -> Set<Int> {
        let raw = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        return Set(raw)
    }

    // MARK: - コメント

    func comments(for car: Car) -> [CommentItem] {
        comments[car.id] ?? []
    }

    /// 車詳細を開いたときに D1 のコメントを取得する（空ならモックの初期コメントを維持）。
    func loadComments(for car: Car) async {
        guard let remote = try? await repository.comments(carID: car.id), !remote.isEmpty else { return }
        comments[car.id] = remote
    }

    func addComment(_ text: String, to car: Car) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = CommentItem(user: currentUser?.name ?? "あなた", text: trimmed, time: "たった今")
        comments[car.id, default: []].insert(item, at: 0)
        Task {
            try? await repository.addComment(trimmed, carID: car.id)
        }
    }

    // MARK: - トーク

    /// 開いているチャットの WebSocket（部屋 = 友達ごとの Durable Object）
    private var socket: ChatSocket?
    private var activeFriendID: UUID?
    /// サーバー由来メッセージの重複排除（自分の送信エコーを含む）
    private var seenWireIDs: Set<String> = []

    /// 友達との DM の部屋 ID（friendships ベース）。
    /// 双方から同じ ID になるよう、小さいユーザー ID を先にする。
    private func roomID(for friend: Friend) -> String {
        guard let me = currentUser?.id, let friendID = friend.userID else {
            // 未ログインのローカルモック用（サーバーには接続しない）
            return "dm-\(friend.name)"
        }
        return "dm-\(min(me, friendID))-\(max(me, friendID))"
    }

    /// チャット画面を開いたときに呼ぶ。部屋に接続し、履歴とリアルタイム配信を受ける。
    /// 送信者は認証ユーザー。未ログインの場合は接続せず、ローカルのみで動く。
    func openChat(_ friend: Friend) {
        closeChat()
        guard currentUser != nil, friend.userID != nil, let token = AuthService.token else { return }
        let socket = ChatSocket()
        self.socket = socket
        activeFriendID = friend.id
        socket.onEvent = { [weak self] event in
            self?.handle(event, for: friend)
        }
        socket.connect(roomID: roomID(for: friend), token: token)
    }

    func closeChat() {
        socket?.disconnect()
        socket = nil
        activeFriendID = nil
    }

    private func handle(_ event: ChatServerEvent, for friend: Friend) {
        switch event.type {
        case "history":
            // サーバーに履歴があればそれを正とする（なければモックの初期チャットを維持）
            guard let wires = event.messages, !wires.isEmpty else { return }
            seenWireIDs = Set(wires.map(\.id))
            chats[friend.id] = wires.map { chatMessage(from: $0, friend: friend) }
            if let last = wires.last {
                updateLast(last.text ?? "車をシェアしました", for: friend)
            }
        case "message":
            guard let wire = event.message, !seenWireIDs.contains(wire.id) else { return }
            seenWireIDs.insert(wire.id)
            chats[friend.id, default: []].append(chatMessage(from: wire, friend: friend))
            updateLast(wire.text ?? "車をシェアしました", for: friend)
        default:
            break
        }
    }

    private func chatMessage(from wire: WireChatMessage, friend: Friend) -> ChatMessage {
        let me = currentUser.map { wire.sender == "user-\($0.id)" } ?? false
        return ChatMessage(
            me: me,
            text: wire.text,
            who: me ? nil : (wire.senderName ?? friend.name),
            carID: wire.carID
        )
    }

    func messages(for friend: Friend) -> [ChatMessage] {
        chats[friend.id] ?? []
    }

    func send(_ text: String, to friend: Friend) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let socket, socket.isConnected, activeFriendID == friend.id {
            // サーバー経由（自分にもエコーが返り、handle で追加される）
            socket.send(text: trimmed)
        } else {
            // オフライン時のフォールバック（ローカルのみ）
            chats[friend.id, default: []].append(ChatMessage(me: true, text: trimmed))
        }
        updateLast(trimmed, for: friend)
    }

    /// 車詳細の共有ボタンから、車カードをトークへ送る。
    /// チャット画面を開く前に呼ばれるため WebSocket ではなく REST（POST /share）を使う。
    /// 未ログイン時はローカル表示のみ（サーバー履歴には残らない）。
    func share(_ car: Car, with friend: Friend) {
        chats[friend.id, default: []].append(ChatMessage(me: true, text: nil, who: nil, carID: car.id))
        updateLast("\(car.maker) \(car.name) をシェアしました", for: friend)

        guard let token = AuthService.token else { return }
        var request = URLRequest(
            url: ChatSocket.httpBaseURL.appending(path: "api/chat/\(roomID(for: friend))/share")
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["car_id": car.id])
        Task {
            // 失敗してもローカル表示は残す（サーバー履歴には残らない）
            _ = try? await URLSession.shared.data(for: request)
        }
    }

    func markRead(_ friend: Friend) {
        guard let index = friends.firstIndex(of: friend) else { return }
        friends[index].unread = 0
    }

    private func updateLast(_ text: String, for friend: Friend) {
        guard let index = friends.firstIndex(of: friend) else { return }
        friends[index].last = text
    }

    // MARK: - プレビュー用（同期でデータを充填した状態）

    static var preview: AppStore {
        let store = AppStore()
        store.cars = MockData.cars
        store.news = MockData.news
        store.featured = MockData.featuredCarIDs.compactMap { id in
            MockData.cars.first { $0.id == id }
        }
        return store
    }
}

/// 各画面の `#Preview` で使う共通ストア。
func previewStore() -> AppStore { .preview }
