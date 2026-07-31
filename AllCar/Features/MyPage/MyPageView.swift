import SwiftUI

/// マイページ：未ログインなら登録／ログインフォーム、ログイン済みならプロフィールを表示する。
struct MyPageView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if let user = store.currentUser {
                    ProfileView(user: user)
                } else {
                    AuthFormView()
                }
            }
            .navigationTitle("マイページ")
        }
    }
}

// MARK: - 登録／ログインフォーム

private struct AuthFormView: View {
    @Environment(AppStore.self) private var store

    private enum Mode: String, CaseIterable {
        case register = "新規登録"
        case login = "ログイン"
    }

    @State private var mode: Mode = .register
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        Form {
            Section {
                Picker("モード", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section {
                if mode == .register {
                    TextField("名前", text: $name)
                        .textContentType(.name)
                }
                TextField("メールアドレス", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("パスワード（6文字以上）", text: $password)
                    .textContentType(mode == .register ? .newPassword : .password)
            } footer: {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(mode.rawValue)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isSubmitting || !canSubmit)
            } footer: {
                Text("アカウントはコメント投稿などで使われます。パスワードはサーバー側でハッシュ化して保存されます。")
            }
        }
        .onChange(of: mode) { errorMessage = nil }
    }

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6 && (mode == .login || !name.isEmpty)
    }

    private func submit() {
        errorMessage = nil
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                switch mode {
                case .register:
                    try await store.register(name: name, email: email, password: password)
                case .login:
                    try await store.login(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - プロフィール

private struct ProfileView: View {
    let user: UserAccount
    @Environment(AppStore.self) private var store

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.accentColor.gradient)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                        )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("利用状況") {
                LabeledContent("お気に入り", value: "\(store.favoriteCars.count) 台")
                LabeledContent("ユーザー ID", value: "#\(user.id)")
            }

            Section {
                Button("ログアウト", role: .destructive) {
                    store.logout()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    MyPageView()
        .environment(previewStore())
        .environment(Navigation())
}
