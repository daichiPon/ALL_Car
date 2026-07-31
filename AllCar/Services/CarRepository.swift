import Foundation

/// データ取得の窓口。
/// 本番は Cloudflare Workers + D1 を叩く `APICarRepository`、
/// オフライン・プレビューはローカルの `MockCarRepository` を使う。
protocol CarRepository: Sendable {
    func makers() async throws -> [String]
    func cars(maker: String?, model: String?, transType: TransType?) async throws -> [Car]
    func car(id: Int) async throws -> Car?
    func news() async throws -> [NewsItem]
    func featuredCars() async throws -> [Car]
    func comments(carID: Int) async throws -> [CommentItem]
    func addComment(_ text: String, carID: Int) async throws
}

struct MockCarRepository: CarRepository {

    func makers() async throws -> [String] {
        Array(Set(MockData.cars.map(\.maker))).sorted()
    }

    func cars(maker: String?, model: String?, transType: TransType?) async throws -> [Car] {
        MockData.cars.filter { car in
            if let maker, car.maker != maker { return false }
            if let model, car.name != model { return false }
            if let transType, car.transType != transType { return false }
            return true
        }
    }

    func car(id: Int) async throws -> Car? {
        MockData.cars.first { $0.id == id }
    }

    func news() async throws -> [NewsItem] {
        MockData.news
    }

    func featuredCars() async throws -> [Car] {
        MockData.featuredCarIDs.compactMap { id in
            MockData.cars.first { $0.id == id }
        }
    }

    func comments(carID: Int) async throws -> [CommentItem] {
        MockData.comments[carID] ?? []
    }

    func addComment(_ text: String, carID: Int) async throws {
        // ローカルモックでは何もしない（AppStore 側でメモリに追加される）
    }
}
