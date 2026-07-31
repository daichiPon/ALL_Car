import SwiftUI

struct ChatView: View {
    let friend: Friend

    @Environment(AppStore.self) private var store
    @State private var draft = ""

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(store.messages(for: friend)) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(16)
            }
            .onChange(of: store.messages(for: friend).count) {
                if let last = store.messages(for: friend).last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            composer
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.markRead(friend)
            store.openChat(friend)
        }
        .onDisappear { store.closeChat() }
    }

    private var composer: some View {
        VStack(spacing: 6) {
            if store.currentUser == nil {
                Text("ログインするとリアルタイムで送受信できます（マイページから）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .bottom, spacing: 8) {
                TextField("メッセージを入力", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button {
                    store.send(draft, to: friend)
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                }
                .buttonStyle(.borderless)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("送信")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack {
            if message.me { Spacer(minLength: 40) }

            VStack(alignment: message.me ? .trailing : .leading, spacing: 6) {
                if let carID = message.carID, let car = store.car(id: carID) {
                    SharedCarCard(car: car)
                }
                if let text = message.text {
                    Text(text)
                        .foregroundStyle(message.me ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            message.me ? Color.accentColor : Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                }
            }

            if !message.me { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(friend: MockData.friends[0])
    }
    .environment(previewStore())
    .environment(Navigation())
}
