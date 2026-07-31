import Foundation

// MARK: - 車

enum TransType: String, CaseIterable, Identifiable, Hashable {
    case at = "AT"
    case mt = "MT"

    var id: String { rawValue }
}

struct Car: Identifiable, Hashable {
    let id: Int
    let maker: String        // メーカー名
    let name: String         // 車種名
    let body: String         // ボディタイプ
    let drive: String        // FF / FR / MR / RR / RWD / 4WD / AWD
    let trans: String        // 6MT / CVT / 8AT ...
    let transType: TransType // 絞り込み用
    let power: Int           // 最高出力 (PS)
    let disp: String         // エンジン／パワートレイン
    let fuel: String         // 燃費(km/L) または 航続距離
    let price: Int           // 新車価格（万円）
    let colorHex: String     // 表示アクセント色
    let ev: Bool
    let tag: String          // キャッチ
}

// MARK: - コメント

struct CommentItem: Identifiable, Hashable {
    let id = UUID()
    let user: String
    let text: String
    let time: String
}

// MARK: - 友達

struct Friend: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var last: String
    var unread: Int
    let active: Bool
    /// D1 の users.id。friendships 由来の実友達だけが持つ（モックは nil）。
    var userID: Int? = nil
}

// MARK: - チャット

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let me: Bool
    var text: String?
    var who: String?
    var carID: Int?
}

// MARK: - ニュース

struct NewsItem: Identifiable, Hashable {
    let id: Int
    let cat: String
    let title: String
    let time: String
    let src: String
}

// MARK: - ブランドバッジ

struct BrandBadgeStyle: Hashable {
    let colorHex: String
    let mono: String   // 頭文字
}
