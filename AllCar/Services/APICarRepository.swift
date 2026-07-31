import Foundation

/// Cloudflare Workers (allcar-api) + D1 を叩く本番リポジトリ（README 8章・10章）。
/// 通信に失敗した場合はローカルカタログ（MockCarRepository）へフォールバックし、
/// オフラインでもアプリが使える状態を保つ。
struct APICarRepository: CarRepository {

    static let baseURL = URL(string: "https://allcar-api.nakamoto-allcar.workers.dev")!
    private let fallback = MockCarRepository()

    // MARK: - DTO（Worker が返す JSON の形）

    private struct CarDTO: Decodable {
        let id: Int
        let maker: String
        let name: String
        let body: String
        let drive: String
        let trans: String
        let transType: String
        let power: Int
        let disp: String
        let fuel: String
        let price: Int
        let color: String
        let ev: Bool
        let tag: String

        var car: Car {
            Car(id: id, maker: maker, name: name, body: body, drive: drive,
                trans: trans, transType: TransType(rawValue: transType) ?? .at,
                power: power, disp: disp, fuel: fuel, price: price,
                colorHex: color, ev: ev, tag: tag)
        }
    }

    private struct MakerDTO: Decodable {
        let id: Int
        let name: String
        let badgeColor: String?
    }

    private struct NewsDTO: Decodable {
        let id: Int
        let cat: String
        let title: String
        let time: String
        let src: String
    }

    private struct CommentDTO: Decodable {
        let user: String
        let text: String
        let time: String
    }

    // MARK: - 通信

    private func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(
            url: Self.baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )!
        if !query.isEmpty { components.queryItems = query }
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - CarRepository

    func makers() async throws -> [String] {
        do {
            let makers: [MakerDTO] = try await get("api/makers")
            return makers.map(\.name)
        } catch {
            return try await fallback.makers()
        }
    }

    func cars(maker: String?, model: String?, transType: TransType?) async throws -> [Car] {
        do {
            var query: [URLQueryItem] = []
            if let maker { query.append(.init(name: "maker", value: maker)) }
            if let model { query.append(.init(name: "model", value: model)) }
            if let transType { query.append(.init(name: "trans", value: transType.rawValue)) }
            let dtos: [CarDTO] = try await get("api/cars", query: query)
            return dtos.map(\.car)
        } catch {
            return try await fallback.cars(maker: maker, model: model, transType: transType)
        }
    }

    func car(id: Int) async throws -> Car? {
        do {
            let dto: CarDTO = try await get("api/cars/\(id)")
            return dto.car
        } catch {
            return try await fallback.car(id: id)
        }
    }

    func news() async throws -> [NewsItem] {
        do {
            let dtos: [NewsDTO] = try await get("api/news")
            return dtos.map { NewsItem(id: $0.id, cat: $0.cat, title: $0.title, time: $0.time, src: $0.src) }
        } catch {
            return try await fallback.news()
        }
    }

    func featuredCars() async throws -> [Car] {
        let all = try await cars(maker: nil, model: nil, transType: nil)
        return MockData.featuredCarIDs.compactMap { id in all.first { $0.id == id } }
    }

    func comments(carID: Int) async throws -> [CommentItem] {
        do {
            let dtos: [CommentDTO] = try await get("api/cars/\(carID)/comments")
            return dtos.map { CommentItem(user: $0.user, text: $0.text, time: $0.time) }
        } catch {
            return try await fallback.comments(carID: carID)
        }
    }

    func addComment(_ text: String, carID: Int) async throws {
        var request = URLRequest(url: Self.baseURL.appending(path: "api/cars/\(carID)/comments"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // ログイン済みなら本人名義で投稿される（未ログインはゲスト扱い）
        if let token = AuthService.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["body": text])
        _ = try await URLSession.shared.data(for: request)
    }
}
