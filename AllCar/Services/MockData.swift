import Foundation

/// フェーズ 1 でバックエンド（Cloudflare Workers + D1）に置き換える前提のローカルデータ。
/// `CarRepository` 経由でのみ参照すること。
enum MockData {

    // MARK: - 車

    /// 全ブランド・全車種は `CarCatalog`（地域別ファイル）に定義している。
    static let cars: [Car] = CarCatalog.all

    // MARK: - ブランドバッジ

    /// ロゴは商標の都合で使わず、頭文字バッジで代用する（README 12 章）。
    static func brandStyle(for maker: String) -> BrandBadgeStyle {
        CarCatalog.brandStyles[maker] ?? .init(colorHex: "#3B5BF5", mono: String(maker.prefix(1)).uppercased())
    }

    // MARK: - ニュース

    static let news: [NewsItem] = [
        NewsItem(id: 1, cat: "新型",
                 title: "新型スポーツクーペ、来春デビューへ ─ 2.0L ターボ + 6MT を継続",
                 time: "1 時間前", src: "All Car 編集部"),
        NewsItem(id: 2, cat: "EV",
                 title: "軽 EV の航続距離が 250km 級へ ─ 次期モデルで電池刷新",
                 time: "3 時間前", src: "All Car 編集部"),
        NewsItem(id: 3, cat: "試乗",
                 title: "直 6 ディーゼル SUV に長距離試乗 ─ 実燃費は 18km/L 台",
                 time: "昨日", src: "All Car 編集部"),
        NewsItem(id: 4, cat: "モータースポーツ",
                 title: "国内ラリー選手権、ホモロゲモデルが 3 連勝",
                 time: "2 日前", src: "All Car 編集部"),
        NewsItem(id: 5, cat: "相場",
                 title: "国産スポーツの中古相場、MT 車を中心に高止まり",
                 time: "3 日前", src: "All Car 編集部")
    ]

    /// 注目の新車（ホームの横スクロール）
    static let featuredCarIDs: [Int] = [301, 401, 101, 212, 2001, 407, 103]

    // MARK: - コメント

    static let comments: [Int: [CommentItem]] = [
        101: [   // GR ヤリス
            CommentItem(user: "たくみ", text: "4WD の安定感がすごい。雪道でも安心。", time: "2 時間前"),
            CommentItem(user: "R_fan", text: "納期どのくらいでした？", time: "昨日")
        ],
        301: [   // シビック TYPE R
            CommentItem(user: "しんじ", text: "FF とは思えない曲がり方。峠が楽しい。", time: "30 分前"),
            CommentItem(user: "みか", text: "リアウイング、意外と後方視界いけます。", time: "5 時間前"),
            CommentItem(user: "TypeR乗り", text: "純正シートの出来が最高。", time: "2 日前")
        ],
        401: [   // フェアレディZ
            CommentItem(user: "ゆうすけ", text: "V6 ツインターボのトルクが太い。", time: "1 時間前")
        ],
        501: [   // ロードスター
            CommentItem(user: "まさ", text: "屋根開けて走るだけで元が取れる。", time: "4 時間前")
        ],
        311: [   // N-BOX
            CommentItem(user: "ゆき", text: "後席の広さが本当に反則。", time: "昨日")
        ]
    ]

    // MARK: - 友達・トーク

    static let friends: [Friend] = [
        Friend(name: "たくみ",   last: "そのグレード、MT あるの？", unread: 2, active: true),
        Friend(name: "みか",     last: "写真ありがとう！",           unread: 0, active: true),
        Friend(name: "しんじ",   last: "週末どこか走りに行く？",     unread: 1, active: false),
        Friend(name: "ゆうすけ", last: "見積もり出たら送るね",       unread: 0, active: false)
    ]

    static func initialChat(for friend: Friend) -> [ChatMessage] {
        switch friend.name {
        case "たくみ":
            return [
                ChatMessage(me: false, text: "この前の車、結局どうした？", who: "たくみ"),
                ChatMessage(me: true,  text: "まだ悩み中。MT が欲しいんだよね"),
                ChatMessage(me: false, text: "そのグレード、MT あるの？", who: "たくみ")
            ]
        case "みか":
            return [
                ChatMessage(me: true,  text: "展示車の写真送るね"),
                ChatMessage(me: false, text: "写真ありがとう！", who: "みか")
            ]
        case "しんじ":
            return [
                ChatMessage(me: false, text: "週末どこか走りに行く？", who: "しんじ")
            ]
        default:
            return [
                ChatMessage(me: false, text: "見積もり出たら送るね", who: friend.name)
            ]
        }
    }
}
