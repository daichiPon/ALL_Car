import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                // 注目の新車（横スクロール）
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.featured) { car in
                                FeaturedCarCard(car: car)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    Text("注目の新車")
                }

                // ニュース
                Section("最近の車ニュース") {
                    ForEach(store.news) { item in
                        NewsRow(item: item)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ALL CAR")
        }
    }
}

private struct NewsRow: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                TagChip(text: item.cat)
                Text(item.time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(item.src)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HomeView()
        .environment(previewStore())
        .environment(Navigation())
}
