import SwiftUI

// MARK: - 注目の新車カード（ホームの横スクロール）

struct FeaturedCarCard: View {
    let car: Car
    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation

    var body: some View {
        Button {
            navigation.presentedCar = car
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // 実車画像は R2 から配信する想定。今はアクセント色のプレースホルダ。
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [Color(hex: car.colorHex).opacity(0.9), Color(hex: car.colorHex).opacity(0.25)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(height: 108)
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: car.ev ? "bolt.car.fill" : "car.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(12)
                    }

                    FavoriteButton(isOn: store.isFavorite(car)) {
                        store.toggleFavorite(car)
                    }
                    .padding(7)
                    .background(.thinMaterial, in: Circle())
                    .padding(8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(car.maker.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(car.name)
                        .font(.headline)
                        .lineLimit(1)
                    TagChip(text: car.tag, color: Color(hex: car.colorHex))
                    PriceLabel(price: car.price)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(width: 208)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 車の行（一覧・お気に入り）

struct CarRow: View {
    let car: Car

    @Environment(Navigation.self) private var navigation

    var body: some View {
        Button {
            navigation.presentedCar = car
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: car.colorHex).gradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: car.ev ? "bolt.fill" : "car.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(car.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text("\(car.maker) ・ \(car.body) ・ \(car.trans)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    PriceLabel(price: car.price)
                        .font(.subheadline)
                    Text("\(car.power) PS")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - トークにシェアされた車カード

struct SharedCarCard: View {
    let car: Car
    @Environment(Navigation.self) private var navigation

    var body: some View {
        Button {
            navigation.presentedCar = car
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(hex: car.colorHex).gradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: car.ev ? "bolt.fill" : "car.fill")
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(car.maker)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(car.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    PriceLabel(price: car.price)
                        .font(.caption)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(10)
            .frame(width: 220)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
