import Foundation

/// 米国・韓国・中国などのブランド（Tesla / Hyundai / BYD / Jeep / Land Rover /
/// Cadillac / Chevrolet）。
extension CarCatalog {

    // MARK: - Tesla (1701...)

    static let tesla: [Car] = [
        Car(id: 1701, maker: "Tesla", name: "モデル 3", body: "セダン", drive: "RWD",
            trans: "AT", transType: .at, power: 283, disp: "EV 60kWh", fuel: "航続 573km",
            price: 531, colorHex: "#C62828", ev: true, tag: "EV のベンチマーク"),
        Car(id: 1702, maker: "Tesla", name: "モデル Y", body: "SUV", drive: "RWD",
            trans: "AT", transType: .at, power: 299, disp: "EV 75kWh", fuel: "航続 545km",
            price: 545, colorHex: "#B71C1C", ev: true, tag: "世界一売れた EV"),
        Car(id: 1703, maker: "Tesla", name: "モデル S", body: "セダン", drive: "AWD",
            trans: "AT", transType: .at, power: 670, disp: "EV 100kWh", fuel: "航続 634km",
            price: 1300, colorHex: "#D32F2F", ev: true, tag: "EV 革命の象徴"),
        Car(id: 1704, maker: "Tesla", name: "モデル X", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 670, disp: "EV 100kWh", fuel: "航続 576km",
            price: 1400, colorHex: "#E53935", ev: true, tag: "ファルコンウィング")
    ]

    // MARK: - Hyundai (1801...)

    static let hyundai: [Car] = [
        Car(id: 1801, maker: "Hyundai", name: "アイオニック 5", body: "SUV", drive: "RWD",
            trans: "AT", transType: .at, power: 225, disp: "EV 84kWh", fuel: "航続 703km",
            price: 542, colorHex: "#1A237E", ev: true, tag: "ピクセルデザイン"),
        Car(id: 1802, maker: "Hyundai", name: "アイオニック 5 N", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 650, disp: "EV 84kWh", fuel: "航続 560km",
            price: 858, colorHex: "#0D47A1", ev: true, tag: "サーキットも走れる EV"),
        Car(id: 1803, maker: "Hyundai", name: "コナ", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 204, disp: "EV 64.8kWh", fuel: "航続 625km",
            price: 399, colorHex: "#283593", ev: true, tag: "使い勝手の電動 SUV"),
        Car(id: 1804, maker: "Hyundai", name: "ネッソ", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 163, disp: "FCEV 水素", fuel: "航続 820km",
            price: 777, colorHex: "#303F9F", ev: true, tag: "水素 SUV"),
        Car(id: 1805, maker: "Hyundai", name: "インスター", body: "コンパクト", drive: "FF",
            trans: "AT", transType: .at, power: 115, disp: "EV 49kWh", fuel: "航続 458km",
            price: 285, colorHex: "#3949AB", ev: true, tag: "手が届く EV")
    ]

    // MARK: - BYD (1901...)

    static let byd: [Car] = [
        Car(id: 1901, maker: "BYD", name: "ドルフィン", body: "コンパクト", drive: "FF",
            trans: "AT", transType: .at, power: 95, disp: "EV 44.9kWh", fuel: "航続 400km",
            price: 299, colorHex: "#00695C", ev: true, tag: "価格破壊の EV"),
        Car(id: 1902, maker: "BYD", name: "アット 3", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 204, disp: "EV 58.6kWh", fuel: "航続 470km",
            price: 450, colorHex: "#00796B", ev: true, tag: "ブレードバッテリー"),
        Car(id: 1903, maker: "BYD", name: "シール", body: "セダン", drive: "AWD",
            trans: "AT", transType: .at, power: 530, disp: "EV 82.6kWh", fuel: "航続 575km",
            price: 605, colorHex: "#004D40", ev: true, tag: "電動スポーツセダン"),
        Car(id: 1904, maker: "BYD", name: "シーライオン 7", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 530, disp: "EV 82.6kWh", fuel: "航続 540km",
            price: 528, colorHex: "#00897B", ev: true, tag: "電動クーペ SUV")
    ]

    // MARK: - Jeep (2801...)

    static let jeep: [Car] = [
        Car(id: 2801, maker: "Jeep", name: "ラングラー", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 272, disp: "2.0L Turbo", fuel: "9.6",
            price: 859, colorHex: "#33691E", ev: false, tag: "オフロードの象徴"),
        Car(id: 2802, maker: "Jeep", name: "グランドチェロキー", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 272, disp: "2.0L Turbo", fuel: "9.3",
            price: 899, colorHex: "#2E7D32", ev: false, tag: "プレミアムジープ"),
        Car(id: 2803, maker: "Jeep", name: "コンパス", body: "SUV", drive: "4WD",
            trans: "9AT", transType: .at, power: 175, disp: "2.4L NA", fuel: "12.0",
            price: 599, colorHex: "#1B5E20", ev: false, tag: "日常のジープ"),
        Car(id: 2804, maker: "Jeep", name: "アベンジャー", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 156, disp: "EV 54kWh", fuel: "航続 486km",
            price: 580, colorHex: "#388E3C", ev: true, tag: "ジープ初の EV"),
        Car(id: 2805, maker: "Jeep", name: "グラディエーター", body: "ピックアップ", drive: "4WD",
            trans: "8AT", transType: .at, power: 285, disp: "3.6L V6 NA", fuel: "7.8",
            price: 920, colorHex: "#4E342E", ev: false, tag: "ジープのピックアップ")
    ]

    // MARK: - Land Rover (2901...)

    static let landRover: [Car] = [
        Car(id: 2901, maker: "Land Rover", name: "レンジローバー", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 400, disp: "3.0L 直6 Turbo MHEV", fuel: "8.6",
            price: 2444, colorHex: "#1B5E20", ev: false, tag: "SUV の貴族"),
        Car(id: 2902, maker: "Land Rover", name: "レンジローバー スポーツ", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 400, disp: "3.0L 直6 Turbo MHEV", fuel: "9.0",
            price: 1600, colorHex: "#2E7D32", ev: false, tag: "動的なレンジ"),
        Car(id: 2903, maker: "Land Rover", name: "レンジローバー ヴェラール", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 250, disp: "2.0L Turbo", fuel: "10.1",
            price: 999, colorHex: "#33691E", ev: false, tag: "ミニマルデザイン"),
        Car(id: 2904, maker: "Land Rover", name: "レンジローバー イヴォーク", body: "SUV", drive: "4WD",
            trans: "9AT", transType: .at, power: 200, disp: "2.0L Turbo", fuel: "11.0",
            price: 779, colorHex: "#388E3C", ev: false, tag: "都会のレンジ"),
        Car(id: 2905, maker: "Land Rover", name: "ディフェンダー", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 300, disp: "3.0L 直6 Diesel MHEV", fuel: "11.0",
            price: 899, colorHex: "#43A047", ev: false, tag: "冒険の道具"),
        Car(id: 2906, maker: "Land Rover", name: "ディスカバリー", body: "SUV", drive: "4WD",
            trans: "8AT", transType: .at, power: 300, disp: "3.0L 直6 Diesel MHEV", fuel: "10.8",
            price: 998, colorHex: "#66BB6A", ev: false, tag: "7 人乗り探検家")
    ]

    // MARK: - Cadillac (3801...)

    static let cadillac: [Car] = [
        Car(id: 3801, maker: "Cadillac", name: "リリック", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 528, disp: "EV 102kWh", fuel: "航続 620km",
            price: 1090, colorHex: "#4527A0", ev: true, tag: "キャデラックの電動旗艦"),
        Car(id: 3802, maker: "Cadillac", name: "エスカレード", body: "SUV", drive: "4WD",
            trans: "10AT", transType: .at, power: 426, disp: "6.2L V8 NA", fuel: "5.5",
            price: 1760, colorHex: "#311B92", ev: false, tag: "アメリカンフルサイズ")
    ]

    // MARK: - Chevrolet (3901...)

    static let chevrolet: [Car] = [
        Car(id: 3901, maker: "Chevrolet", name: "コルベット", body: "クーペ", drive: "MR",
            trans: "8AT", transType: .at, power: 502, disp: "6.2L V8 NA", fuel: "7.9",
            price: 1590, colorHex: "#F9A825", ev: false, tag: "ミッドシップ化した伝説"),
        Car(id: 3902, maker: "Chevrolet", name: "コルベット Z06", body: "クーペ", drive: "MR",
            trans: "8AT", transType: .at, power: 646, disp: "5.5L V8 NA", fuel: "7.0",
            price: 2960, colorHex: "#F57F17", ev: false, tag: "フラットプレーン V8")
    ]
}
