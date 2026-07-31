import SwiftUI

/// デザイントークン。
/// HIG に沿ってレイアウト・配色・タイポグラフィはシステム標準
/// （セマンティックカラー / Dynamic Type / 標準コンポーネント）に任せ、
/// ここではブランド固有の値だけを持つ。
enum Theme {
    /// ブランドアクセントカラー（ライト／ダーク両対応の青）
    static let accent = Color(hex: "#3B5BF5")
}

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        switch s.count {
        case 8:
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        case 6:
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
