import SwiftUI

struct FavoritesView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.favoriteCars.isEmpty {
                    ContentUnavailableView(
                        "お気に入りはまだありません",
                        systemImage: "heart",
                        description: Text("気になる車のハートを押すと、ここに集まります。")
                    )
                } else {
                    List {
                        ForEach(store.favoriteCars) { car in
                            CarRow(car: car)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.toggleFavorite(car)
                                    } label: {
                                        Label("削除", systemImage: "heart.slash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("お気に入り")
        }
    }
}

#Preview {
    FavoritesView()
        .environment(previewStore())
        .environment(Navigation())
}
