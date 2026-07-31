import SwiftUI

@main
struct AllCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = AppStore()
    @State private var navigation = Navigation()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(navigation)
                .tint(Theme.accent)
                .task {
                    configurePush()
                    await store.load()
                    if store.currentUser != nil {
                        PushManager.shared.enable()
                    }
                    applyLaunchArguments()
                }
                // ログイン（登録・復元）したらプッシュ通知を有効化する
                .onChange(of: store.currentUser) { _, user in
                    if user != nil {
                        PushManager.shared.enable()
                    }
                }
        }
    }

    /// 通知タップで該当の友達とのチャットを開けるようにする。
    private func configurePush() {
        PushManager.shared.configure()
        PushManager.shared.openChatWithUser = { userID in
            guard let friend = store.friends.first(where: { $0.userID == userID }) else { return }
            store.selectedTab = .talk
            navigation.openChatWith = friend
        }
    }

    /// スクリーンショット確認用。`-screen search|favorites|talk|detail` で起動位置を指定する。
    private func applyLaunchArguments() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-screen"), index + 1 < args.count else { return }
        switch args[index + 1] {
        case "search", "searchresult":
            store.selectedTab = .search
        case "favorites":
            store.selectedTab = .favorites
            MockData.featuredCarIDs.prefix(3).compactMap { store.car(id: $0) }.forEach {
                if !store.isFavorite($0) { store.toggleFavorite($0) }
            }
        case "talk":      store.selectedTab = .talk
        case "detail":    navigation.presentedCar = store.car(id: 301)
        default:          break
        }
        #endif
    }
}
