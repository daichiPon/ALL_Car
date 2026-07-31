import Foundation
import UIKit
import UserNotifications

/// プッシュ通知（README フェーズ3）。
///
/// 流れ:
/// 1. ログイン後に `enable()` → 通知許可 → APNs 登録
/// 2. AppDelegate 経由でデバイストークンを受け取り、`POST /api/devices` で D1 に保存
/// 3. トーク受信時、allcar-chat（Durable Object）が APNs へ送信
/// 4. 通知タップで該当の友達とのチャットを開く（`openChat` フック）
///
/// 実際の配信には Apple Developer Program の APNs キーが必要
/// （Worker 側のシークレット未設定の間は送信されない）。
@MainActor
final class PushManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = PushManager()

    /// 通知タップ時に相手とのチャットを開くフック（引数は相手の userID）。AllCarApp が設定する。
    var openChatWithUser: ((Int) -> Void)?

    private var deviceToken: String?

    /// アプリ起動時に一度呼ぶ。
    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    /// ログイン後に呼ぶ: 許可をリクエストして APNs に登録する。
    func enable() {
        Task {
            let center = UNUserNotificationCenter.current()
            let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
            guard granted else { return }
            UIApplication.shared.registerForRemoteNotifications()
            await uploadTokenIfPossible()
        }
    }

    /// AppDelegate から呼ばれる。
    func didRegister(deviceToken data: Data) {
        deviceToken = data.map { String(format: "%02x", $0) }.joined()
        Task { await uploadTokenIfPossible() }
    }

    /// デバイストークンとログインが揃っていたらサーバーへ登録する。
    private func uploadTokenIfPossible() async {
        guard let deviceToken, let token = AuthService.token else { return }
        var request = URLRequest(url: APICarRepository.baseURL.appending(path: "api/devices"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": deviceToken])
        _ = try? await URLSession.shared.data(for: request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// フォアグラウンドでもバナー・サウンドで表示する。
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    /// 通知タップ → 送信者とのチャットを開く。
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        if let senderID = userInfo["senderUserID"] as? Int {
            openChatWithUser?(senderID)
        }
    }
}

/// APNs のデバイストークン受け取り用（SwiftUI からは AppDelegate 経由でしか取れない）。
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            PushManager.shared.didRegister(deviceToken: deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // 実機以外や Push Notifications capability 未設定時はここに来る
        print("APNs 登録失敗: \(error.localizedDescription)")
    }
}
