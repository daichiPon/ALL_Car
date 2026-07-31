import SwiftUI

/// 車詳細の共有ボタン → 送り先の友達を選び、車カードをトークへ送る。
struct ShareToTalkView: View {
    let car: Car

    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: car.colorHex).gradient)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: car.ev ? "bolt.fill" : "car.fill")
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(car.maker)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(car.name)
                                .font(.body.weight(.semibold))
                        }
                        Spacer()
                        PriceLabel(price: car.price)
                            .font(.subheadline)
                    }
                }

                Section("送り先") {
                    ForEach(store.friends) { friend in
                        Button {
                            store.share(car, with: friend)
                            dismiss()
                            navigation.presentedCar = nil
                            store.selectedTab = .talk
                            navigation.openChatWith = friend
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(.tertiarySystemFill))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Text(String(friend.name.prefix(1)))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                    )
                                Text(friend.name)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("トークにシェア")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("キャンセル") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ShareToTalkView(car: MockData.cars[0])
        .environment(previewStore())
        .environment(Navigation())
}
