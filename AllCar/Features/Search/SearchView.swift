import SwiftUI

/// さがす：入力式ではなく、条件を選択して検索する。
/// HIG に沿って Form ＋ 標準 Picker（メニュー形式）で構成する。
struct SearchView: View {
    @State private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            Form {
                searchCriteria

                if vm.didSearch {
                    resultSections
                } else {
                    Section {
                        ContentUnavailableView(
                            "条件を選んでさがす",
                            systemImage: "slider.horizontal.3",
                            description: Text("メーカー・車種・ミッションから選択して検索できます。")
                        )
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("さがす")
            .toolbar {
                if vm.didSearch {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("リセット") {
                            withAnimation { vm.reset() }
                        }
                    }
                }
            }
            .onChange(of: vm.maker) {
                vm.makerChanged()
            }
            .task {
                #if DEBUG
                // スクリーンショット確認用：`-screen searchresult` で検索済みの状態を再現する
                if ProcessInfo.processInfo.arguments.contains("searchresult"), !vm.didSearch {
                    vm.maker = "Toyota"
                    vm.transType = .mt
                    await vm.search()
                }
                #endif
            }
        }
    }

    // MARK: - 検索条件

    private var searchCriteria: some View {
        Group {
            Section("検索条件") {
                Picker("メーカー", selection: Bindable(vm).maker) {
                    Text("すべて").tag(String?.none)
                    ForEach(vm.makerOptions, id: \.self) { maker in
                        Text(maker).tag(Optional(maker))
                    }
                }

                Picker("車種", selection: Bindable(vm).model) {
                    Text("すべて").tag(String?.none)
                    ForEach(vm.modelOptions, id: \.self) { model in
                        Text(model).tag(Optional(model))
                    }
                }

                Picker("ミッション", selection: Bindable(vm).transType) {
                    Text("すべて").tag(TransType?.none)
                    ForEach(TransType.allCases) { type in
                        Text(type.rawValue).tag(Optional(type))
                    }
                }
            }

            Section {
                Button {
                    Task {
                        await vm.search()
                    }
                } label: {
                    Label("この条件でさがす", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .fontWeight(.semibold)
            }
        }
    }

    // MARK: - 結果：ブランド ▸ 車種

    @ViewBuilder
    private var resultSections: some View {
        if vm.results.isEmpty {
            Section {
                ContentUnavailableView(
                    "該当なし",
                    systemImage: "magnifyingglass",
                    description: Text("条件をゆるめて、もう一度さがしてみてください。")
                )
            }
            .listRowBackground(Color.clear)
        } else {
            Section {
                ForEach(vm.grouped, id: \.brand) { group in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { vm.isExpanded(group.brand) },
                            set: { _ in withAnimation(.snappy) { vm.toggle(group.brand) } }
                        )
                    ) {
                        ForEach(group.cars) { car in
                            BrandCarRow(car: car, highlighted: car.id == vm.highlightedCarID)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            BrandBadge(maker: group.brand)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.brand)
                                    .font(.headline)
                                Text("\(group.cars.count) 車種")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("検索結果")
            } footer: {
                Text("\(vm.results.count) 台 ・ \(vm.conditionSummary)")
            }
        }
    }
}

// MARK: - ブランド内の車種行

private struct BrandCarRow: View {
    let car: Car
    let highlighted: Bool

    @Environment(AppStore.self) private var store
    @Environment(Navigation.self) private var navigation

    var body: some View {
        Button {
            navigation.presentedCar = car
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: car.colorHex))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(car.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(highlighted ? Color.accentColor : .primary)
                    Text("\(car.body) ・ \(car.trans) ・ \(car.power)PS")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                PriceLabel(price: car.price)
                    .font(.subheadline)

                FavoriteButton(isOn: store.isFavorite(car)) {
                    store.toggleFavorite(car)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchView()
        .environment(previewStore())
        .environment(Navigation())
}
