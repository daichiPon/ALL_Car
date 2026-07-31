import Foundation

/// 車の実車画像の配信元（Cloudflare R2）。
///
/// - バケット: `allcar-images`
/// - キー規約: `cars/<車名>.jpg`（例: GR ヤリス → `cars/GR ヤリス.jpg`、カタログの `Car.name` と完全一致）
/// - 画像のアップロード例:
///   `wrangler r2 object put "allcar-images/cars/GR ヤリス.jpg" --file="./GR ヤリス.jpg" --remote`
///
/// 画像が未登録の車は、表示側でプレースホルダにフォールバックする。
/// 本番ではレート制限のない独自ドメインに差し替える想定（この baseURL を変えるだけ）。
enum ImageStore {
    static let baseURL = URL(string: "https://pub-40b9517e31eb44deab08ac736216a598.r2.dev")!

    static func carImageURL(for car: Car) -> URL {
        baseURL.appending(path: "cars/\(car.name).jpg")
    }
}
