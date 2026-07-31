import SwiftUI

struct CarDetailView: View {
    let car: Car

    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""

    var body: some View {
        NavigationStack {
            List {
                header
                specs
                commentSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(car.name)
            .navigationBarTitleDisplayMode(.inline)
            .task { await store.loadComments(for: car) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        store.toggleFavorite(car)
                    } label: {
                        Image(systemName: store.isFavorite(car) ? "heart.fill" : "heart")
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .tint(store.isFavorite(car) ? .red : nil)
                    .accessibilityLabel(store.isFavorite(car) ? "お気に入りから削除" : "お気に入りに追加")

                    Button {
                        navigation.sharingCar = car
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("トークにシェア")
                }
            }
        }
    }

    // MARK: - ヘッダー（メーカー・車名・価格）

    private var header: some View {
        Section {
            // 実車画像（R2 から配信、未登録ならプレースホルダ）
            AsyncImage(url: ImageStore.carImageURL(for: car)) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color(hex: car.colorHex).opacity(0.9), Color(hex: car.colorHex).opacity(0.25)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: car.ev ? "bolt.car.fill" : "car.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipped()
            .listRowInsets(EdgeInsets())
            .accessibilityLabel("\(car.name) の写真")

            HStack(spacing: 12) {
                BrandBadge(maker: car.maker, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(car.maker.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(car.name)
                        .font(.title2.bold())
                }
            }
            .padding(.vertical, 4)

            HStack(spacing: 8) {
                TagChip(text: car.tag, color: Color(hex: car.colorHex))
                TagChip(text: car.body)
                if car.ev { TagChip(text: "EV", color: .green) }
            }

            LabeledContent("新車価格") {
                PriceLabel(price: car.price)
                    .font(.title3)
            }
        }
    }

    // MARK: - 性能ゲージ ＋ スペック

    private var specs: some View {
        Section("スペック") {
            HStack {
                Spacer()
                PowerGauge(power: car.power, tint: Color(hex: car.colorHex))
                Spacer()
            }
            .padding(.vertical, 8)

            LabeledContent("駆動", value: car.drive)
            LabeledContent("ミッション", value: car.trans)
            LabeledContent(car.ev ? "パワートレイン" : "エンジン", value: car.disp)
            LabeledContent(car.ev ? "航続" : "燃費", value: car.ev ? car.fuel : "\(car.fuel) km/L")
        }
    }

    // MARK: - コメント

    private var commentSection: some View {
        Section {
            HStack(spacing: 8) {
                TextField("この車についてコメント", text: $draft, axis: .vertical)
                    .lineLimit(1...4)

                Button {
                    store.addComment(draft, to: car)
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("コメントを送信")
            }

            if store.comments(for: car).isEmpty {
                Text("まだコメントはありません。")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.comments(for: car)) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(comment.user)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(comment.time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(comment.text)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Text("コメント (\(store.comments(for: car).count))")
        }
    }
}

#Preview {
    CarDetailView(car: MockData.cars[1])
        .environment(previewStore())
        .environment(Navigation())
}
