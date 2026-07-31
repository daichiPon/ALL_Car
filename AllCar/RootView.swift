import SwiftUI
import Observation

enum RootTab: Hashable {
    case home, search, favorites, talk, mypage
}

/// 車詳細（オーバーレイ）と、トークへのシェア導線を全画面から扱うためのルーター。
@Observable
final class Navigation {
    var presentedCar: Car?
    var sharingCar: Car?
    /// シェア後に開くトーク相手
    var openChatWith: Friend?
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation

    var body: some View {
        @Bindable var store = store
        @Bindable var navigation = navigation

        TabView(selection: $store.selectedTab) {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }
                .tag(RootTab.home)

            SearchView()
                .tabItem { Label("さがす", systemImage: "magnifyingglass") }
                .tag(RootTab.search)

            FavoritesView()
                .tabItem { Label("お気に入り", systemImage: "heart.fill") }
                .tag(RootTab.favorites)

            TalkView()
                .tabItem { Label("トーク", systemImage: "bubble.left.and.bubble.right.fill") }
                .badge(store.friends.reduce(0) { $0 + $1.unread })
                .tag(RootTab.talk)

            MyPageView()
                .tabItem { Label("マイページ", systemImage: "person.crop.circle") }
                .tag(RootTab.mypage)
        }
        .tint(Theme.accent)
        // 車詳細はオーバーレイ（シート）で表示する
        .sheet(item: $navigation.presentedCar) { car in
            CarDetailView(car: car)
        }
        // 詳細のシェアボタン → 送り先の友達を選ぶ
        .sheet(item: $navigation.sharingCar) { car in
            ShareToTalkView(car: car)
        }
    }
}

#Preview {
    RootView()
        .environment(AppStore())
        .environment(Navigation())
}
