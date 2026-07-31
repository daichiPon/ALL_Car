import SwiftUI

struct TalkView: View {
    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation

    @State private var path: [Friend] = []
    @State private var showAddFriend = false
    @State private var friendEmail = ""
    @State private var addFriendError: String?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if store.currentUser != nil, store.friends.isEmpty {
                    ContentUnavailableView(
                        "友達がいません",
                        systemImage: "person.2",
                        description: Text("右上の＋から、相手のメールアドレスで友達を追加できます。")
                    )
                } else {
                    List {
                        ForEach(store.friends) { friend in
                            NavigationLink(value: friend) {
                                FriendRow(friend: friend)
                            }
                            .badge(friend.unread)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("トーク")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.currentUser == nil {
                            addFriendError = "友達を追加するには、マイページからログインしてください。"
                        } else {
                            showAddFriend = true
                        }
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                    .accessibilityLabel("友達を追加")
                }
            }
            .alert("友達を追加", isPresented: $showAddFriend) {
                TextField("相手のメールアドレス", text: $friendEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                Button("追加") {
                    let email = friendEmail
                    friendEmail = ""
                    Task {
                        do {
                            try await store.addFriend(email: email)
                        } catch {
                            addFriendError = error.localizedDescription
                        }
                    }
                }
                Button("キャンセル", role: .cancel) { friendEmail = "" }
            } message: {
                Text("相手も All Car に登録している必要があります。")
            }
            .alert(
                "友達を追加できません",
                isPresented: Binding(
                    get: { addFriendError != nil },
                    set: { if !$0 { addFriendError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(addFriendError ?? "")
            }
            .navigationDestination(for: Friend.self) { friend in
                ChatView(friend: friend)
            }
        }
        // 車をシェアした直後は、その相手のチャットを開く
        .onChange(of: navigation.openChatWith) { _, friend in
            guard let friend else { return }
            path = [friend]
            navigation.openChatWith = nil
        }
    }
}

private struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(friend.name.prefix(1)))
                            .font(.headline)
                    )
                if friend.active {
                    Circle()
                        .fill(.green)
                        .frame(width: 11, height: 11)
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                        .accessibilityLabel("オンライン")
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.name)
                    .font(.body.weight(.semibold))
                Text(friend.last)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TalkView()
        .environment(previewStore())
        .environment(Navigation())
}
