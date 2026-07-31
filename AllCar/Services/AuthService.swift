import Foundation
import Security

// MARK: - ユーザー

struct UserAccount: Codable, Hashable {
    let id: Int
    let name: String
    let email: String
}

// MARK: - Keychain（README 7章: 認証情報の保管）

enum Keychain {
    static func set(_ value: String, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData as String] = Data(value.utf8)
        SecItemAdd(attributes as CFDictionary, nil)
    }

    static func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - 認証 API（README 10章: /api/auth/*）

enum AuthError: LocalizedError {
    case server(String)

    var errorDescription: String? {
        switch self {
        case .server(let message): message
        }
    }
}

enum AuthService {
    static let tokenKey = "allcar.auth.token"

    static var token: String? { Keychain.get(tokenKey) }

    private struct AuthResponse: Decodable {
        let token: String
        let user: UserAccount
    }
    private struct MeResponse: Decodable { let user: UserAccount }
    private struct ErrorResponse: Decodable { let error: String }

    static func register(name: String, email: String, password: String) async throws -> UserAccount {
        try await authenticate(path: "api/auth/register", body: ["name": name, "email": email, "password": password])
    }

    static func login(email: String, password: String) async throws -> UserAccount {
        try await authenticate(path: "api/auth/login", body: ["email": email, "password": password])
    }

    /// 保存済みトークンでセッションを復元する。トークンが無効なら破棄して nil。
    static func restoreSession() async throws -> UserAccount? {
        guard let token else { return nil }
        var request = URLRequest(url: APICarRepository.baseURL.appending(path: "api/me"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 401 {
            Keychain.delete(tokenKey)
            return nil
        }
        guard status == 200 else { throw AuthError.server("通信エラー (\(status))") }
        return try JSONDecoder().decode(MeResponse.self, from: data).user
    }

    static func logout() {
        Keychain.delete(tokenKey)
    }

    private static func authenticate(path: String, body: [String: String]) async throws -> UserAccount {
        var request = URLRequest(url: APICarRepository.baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error
            throw AuthError.server(message ?? "通信エラー (\(status))")
        }
        let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
        Keychain.set(decoded.token, for: tokenKey)
        return decoded.user
    }
}
