import SwiftUI

// MARK: - ブランドバッジ（頭文字＋ブランドカラーの円）

struct BrandBadge: View {
    let maker: String
    var size: CGFloat = 36

    var body: some View {
        let style = MockData.brandStyle(for: maker)
        Circle()
            .fill(Color(hex: style.colorHex).gradient)
            .frame(width: size, height: size)
            .overlay(
                Text(style.mono)
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
            .accessibilityLabel(maker)
    }
}

// MARK: - 性能ゲージ（計器盤モチーフ）

struct PowerGauge: View {
    /// 最高出力 (PS)
    let power: Int
    /// ゲージの上限
    var maxPower: Int = 600
    var tint: Color = .accentColor
    var size: CGFloat = 148

    private var ratio: Double {
        min(1, max(0, Double(power) / Double(maxPower)))
    }

    var body: some View {
        ZStack {
            // 目盛りの下地（270 度の円弧）
            GaugeArc(ratio: 1)
                .stroke(.quaternary, style: .init(lineWidth: 12, lineCap: .round))

            GaugeArc(ratio: ratio)
                .stroke(
                    AngularGradient(
                        colors: [tint.opacity(0.5), tint],
                        center: .center,
                        startAngle: .degrees(135),
                        endAngle: .degrees(405)
                    ),
                    style: .init(lineWidth: 12, lineCap: .round)
                )

            VStack(spacing: 2) {
                Text("\(power)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
                Text("PS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: 0.5), value: power)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("最高出力 \(power) PS")
    }
}

private struct GaugeArc: Shape {
    var ratio: Double

    var animatableData: Double {
        get { ratio }
        set { ratio = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2 - 6,
            startAngle: .degrees(135),
            endAngle: .degrees(135 + 270 * ratio),
            clockwise: false
        )
        return p
    }
}

// MARK: - タグチップ

struct TagChip: View {
    let text: String
    var color: Color = .accentColor

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
    }
}

// MARK: - お気に入りハート

struct FavoriteButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundStyle(isOn ? Color.red : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isOn ? "お気に入りから削除" : "お気に入りに追加")
    }
}

// MARK: - 価格表記

struct PriceLabel: View {
    let price: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("¥\(price)")
                .fontWeight(.semibold)
                .monospacedDigit()
            Text("万〜")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("新車価格 \(price)万円から")
    }
}
