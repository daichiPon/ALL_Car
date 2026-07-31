import Foundation
import Observation

/// さがす画面（選択式検索）の状態。
/// 入力式ではなくドロップダウン選択なので、選択肢自体もここで組み立てる。
@Observable
final class SearchViewModel {

    // MARK: 選択状態

    var maker: String?
    var model: String?
    var transType: TransType?

    // MARK: 結果

    private(set) var results: [Car] = []
    private(set) var didSearch = false

    /// 検索後に自動展開するブランド
    var expandedBrands: Set<String> = []
    /// 選択した車種（ハイライト用）
    var highlightedCarID: Int?

    private let repository: CarRepository

    init(repository: CarRepository = APICarRepository()) {
        self.repository = repository
    }

    // MARK: - 選択肢

    var makerOptions: [String] {
        Array(Set(MockData.cars.map(\.maker))).sorted()
    }

    /// 車種はメーカーに連動して候補が絞られる。
    var modelOptions: [String] {
        let source = maker.map { m in MockData.cars.filter { $0.maker == m } } ?? MockData.cars
        return source.map(\.name).sorted()
    }

    /// メーカーを変えたら、範囲外になった車種選択は捨てる。
    func makerChanged() {
        if let model, !modelOptions.contains(model) {
            self.model = nil
        }
    }

    var canSearch: Bool {
        maker != nil || model != nil || transType != nil
    }

    var conditionSummary: String {
        var parts: [String] = []
        if let maker { parts.append(maker) }
        if let model { parts.append(model) }
        if let transType { parts.append(transType.rawValue) }
        return parts.isEmpty ? "条件を選択してください" : parts.joined(separator: " ・ ")
    }

    // MARK: - 検索

    func search() async {
        let found = (try? await repository.cars(maker: maker, model: model, transType: transType)) ?? []
        results = found
        didSearch = true
        // 該当ブランドを自動展開し、車種を選んでいればハイライトする
        expandedBrands = Set(found.map(\.maker))
        highlightedCarID = model.flatMap { name in found.first { $0.name == name }?.id }
    }

    func reset() {
        maker = nil
        model = nil
        transType = nil
        results = []
        didSearch = false
        expandedBrands = []
        highlightedCarID = nil
    }

    /// 結果を ブランド → 車種 のネストに整形する。
    var grouped: [(brand: String, cars: [Car])] {
        Dictionary(grouping: results, by: \.maker)
            .map { (brand: $0.key, cars: $0.value.sorted { $0.name < $1.name }) }
            .sorted { $0.brand < $1.brand }
    }

    func isExpanded(_ brand: String) -> Bool {
        expandedBrands.contains(brand)
    }

    func toggle(_ brand: String) {
        if expandedBrands.contains(brand) {
            expandedBrands.remove(brand)
        } else {
            expandedBrands.insert(brand)
        }
    }
}
