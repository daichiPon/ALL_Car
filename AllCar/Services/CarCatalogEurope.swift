import Foundation

/// 欧州ブランドの現行ラインナップ（MINI / Volvo / Peugeot / Renault / Fiat / Abarth /
/// Citroën / Alfa Romeo / Smart / Alpine）。
extension CarCatalog {

    // MARK: - MINI (1501...)

    static let mini: [Car] = [
        Car(id: 1501, maker: "MINI", name: "クーパー 3ドア", body: "コンパクト", drive: "FF",
            trans: "7AT", transType: .at, power: 156, disp: "1.5L Turbo", fuel: "15.4",
            price: 396, colorHex: "#212121", ev: false, tag: "ゴーカートフィール"),
        Car(id: 1502, maker: "MINI", name: "クーパー 5ドア", body: "コンパクト", drive: "FF",
            trans: "7AT", transType: .at, power: 156, disp: "1.5L Turbo", fuel: "15.2",
            price: 411, colorHex: "#37474F", ev: false, tag: "使える MINI"),
        Car(id: 1503, maker: "MINI", name: "コンバーチブル", body: "オープン", drive: "FF",
            trans: "7AT", transType: .at, power: 156, disp: "1.5L Turbo", fuel: "14.8",
            price: 465, colorHex: "#455A64", ev: false, tag: "オープン MINI"),
        Car(id: 1504, maker: "MINI", name: "エースマン", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 184, disp: "EV 54.2kWh", fuel: "航続 406km",
            price: 531, colorHex: "#00695C", ev: true, tag: "EV 専用クロスオーバー"),
        Car(id: 1505, maker: "MINI", name: "カントリーマン", body: "SUV", drive: "AWD",
            trans: "7AT", transType: .at, power: 218, disp: "2.0L Turbo", fuel: "12.8",
            price: 588, colorHex: "#33691E", ev: false, tag: "一番大きな MINI")
    ]

    // MARK: - Volvo (1601...)

    static let volvo: [Car] = [
        Car(id: 1601, maker: "Volvo", name: "EX30", body: "SUV", drive: "RWD",
            trans: "AT", transType: .at, power: 272, disp: "EV 69kWh", fuel: "航続 560km",
            price: 559, colorHex: "#00695C", ev: true, tag: "小さな北欧 EV"),
        Car(id: 1602, maker: "Volvo", name: "EX40", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 408, disp: "EV 78kWh", fuel: "航続 590km",
            price: 799, colorHex: "#004D40", ev: true, tag: "電動コンパクト SUV"),
        Car(id: 1603, maker: "Volvo", name: "EC40", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 408, disp: "EV 78kWh", fuel: "航続 550km",
            price: 819, colorHex: "#00796B", ev: true, tag: "電動クーペ SUV"),
        Car(id: 1604, maker: "Volvo", name: "XC40", body: "SUV", drive: "FF",
            trans: "8AT", transType: .at, power: 197, disp: "2.0L Turbo MHEV", fuel: "13.0",
            price: 599, colorHex: "#1565C0", ev: false, tag: "北欧デザイン SUV"),
        Car(id: 1605, maker: "Volvo", name: "XC60", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 250, disp: "2.0L Turbo MHEV", fuel: "12.6",
            price: 764, colorHex: "#0D47A1", ev: false, tag: "安全の代名詞"),
        Car(id: 1606, maker: "Volvo", name: "XC90", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 250, disp: "2.0L Turbo MHEV", fuel: "11.6",
            price: 1049, colorHex: "#283593", ev: false, tag: "北欧の旗艦 SUV"),
        Car(id: 1607, maker: "Volvo", name: "V60", body: "ワゴン", drive: "FF",
            trans: "8AT", transType: .at, power: 250, disp: "2.0L Turbo MHEV", fuel: "13.6",
            price: 649, colorHex: "#303F9F", ev: false, tag: "エステートの本流")
    ]

    // MARK: - Peugeot (3001...)

    static let peugeot: [Car] = [
        Car(id: 3001, maker: "Peugeot", name: "208", body: "コンパクト", drive: "FF",
            trans: "8AT", transType: .at, power: 100, disp: "1.2L Turbo", fuel: "19.4",
            price: 319, colorHex: "#283593", ev: false, tag: "猫科のコンパクト"),
        Car(id: 3002, maker: "Peugeot", name: "2008", body: "SUV", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.2L Turbo", fuel: "17.9",
            price: 399, colorHex: "#1A237E", ev: false, tag: "牙のデザイン"),
        Car(id: 3003, maker: "Peugeot", name: "308", body: "コンパクト", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.2L Turbo MHEV", fuel: "18.0",
            price: 449, colorHex: "#303F9F", ev: false, tag: "i-Cockpit の世界"),
        Car(id: 3004, maker: "Peugeot", name: "408", body: "セダン", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.2L Turbo", fuel: "16.9",
            price: 499, colorHex: "#3949AB", ev: false, tag: "ファストバックの異端"),
        Car(id: 3005, maker: "Peugeot", name: "3008", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 136, disp: "1.2L Turbo MHEV", fuel: "17.5",
            price: 549, colorHex: "#455A64", ev: false, tag: "新世代ハイブリッド"),
        Car(id: 3006, maker: "Peugeot", name: "5008", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 136, disp: "1.2L Turbo MHEV", fuel: "16.8",
            price: 599, colorHex: "#37474F", ev: false, tag: "7 人乗りフレンチ SUV")
    ]

    // MARK: - Renault (3101...)

    static let renault: [Car] = [
        Car(id: 3101, maker: "Renault", name: "ルーテシア", body: "コンパクト", drive: "FF",
            trans: "AT", transType: .at, power: 145, disp: "1.6L E-TECH HV", fuel: "25.2",
            price: 309, colorHex: "#F9A825", ev: false, tag: "F1 由来のハイブリッド"),
        Car(id: 3102, maker: "Renault", name: "キャプチャー", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 145, disp: "1.6L E-TECH HV", fuel: "22.8",
            price: 379, colorHex: "#F57F17", ev: false, tag: "洒脱なコンパクト SUV"),
        Car(id: 3103, maker: "Renault", name: "アルカナ", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 145, disp: "1.6L E-TECH HV", fuel: "22.8",
            price: 429, colorHex: "#FBC02D", ev: false, tag: "クーペ SUV × HV"),
        Car(id: 3104, maker: "Renault", name: "カングー", body: "ミニバン", drive: "FF",
            trans: "7AT", transType: .at, power: 131, disp: "1.3L Turbo", fuel: "15.3",
            price: 395, colorHex: "#FDD835", ev: false, tag: "フレンチ道具箱")
    ]

    // MARK: - Fiat (3201...) / Abarth (3251...)

    static let fiat: [Car] = [
        Car(id: 3201, maker: "Fiat", name: "500", body: "コンパクト", drive: "FF",
            trans: "5AT", transType: .at, power: 70, disp: "1.0L マイルド HV", fuel: "19.2",
            price: 299, colorHex: "#AD1457", ev: false, tag: "永遠のチンク"),
        Car(id: 3202, maker: "Fiat", name: "500e", body: "コンパクト", drive: "FF",
            trans: "AT", transType: .at, power: 118, disp: "EV 42kWh", fuel: "航続 335km",
            price: 495, colorHex: "#C2185B", ev: true, tag: "電動チンクエチェント"),
        Car(id: 3203, maker: "Fiat", name: "600e", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 156, disp: "EV 54kWh", fuel: "航続 493km",
            price: 585, colorHex: "#D81B60", ev: true, tag: "陽気な電動 SUV")
    ]

    static let abarth: [Car] = [
        Car(id: 3251, maker: "Abarth", name: "695", body: "スポーツ", drive: "FF",
            trans: "5MT", transType: .mt, power: 180, disp: "1.4L Turbo", fuel: "13.0",
            price: 465, colorHex: "#C62828", ev: false, tag: "サソリの毒"),
        Car(id: 3252, maker: "Abarth", name: "500e", body: "スポーツ", drive: "FF",
            trans: "AT", transType: .at, power: 155, disp: "EV 42kWh", fuel: "航続 303km",
            price: 585, colorHex: "#B71C1C", ev: true, tag: "電動サソリ")
    ]

    // MARK: - Citroën (3301...)

    static let citroen: [Car] = [
        Car(id: 3301, maker: "Citroën", name: "C3", body: "コンパクト", drive: "FF",
            trans: "6AT", transType: .at, power: 110, disp: "1.2L Turbo", fuel: "17.9",
            price: 289, colorHex: "#455A64", ev: false, tag: "快適性ファースト"),
        Car(id: 3302, maker: "Citroën", name: "C3 エアクロス", body: "SUV", drive: "FF",
            trans: "6AT", transType: .at, power: 110, disp: "1.2L Turbo", fuel: "17.0",
            price: 339, colorHex: "#546E7A", ev: false, tag: "ゆるふわ SUV"),
        Car(id: 3303, maker: "Citroën", name: "C4", body: "コンパクト", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.2L Turbo", fuel: "17.8",
            price: 419, colorHex: "#37474F", ev: false, tag: "魔法の絨毯"),
        Car(id: 3304, maker: "Citroën", name: "C5 エアクロス", body: "SUV", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.2L Turbo", fuel: "16.1",
            price: 469, colorHex: "#263238", ev: false, tag: "極上の乗り心地"),
        Car(id: 3305, maker: "Citroën", name: "ベルランゴ", body: "ミニバン", drive: "FF",
            trans: "8AT", transType: .at, power: 130, disp: "1.5L Diesel", fuel: "18.1",
            price: 429, colorHex: "#4E342E", ev: false, tag: "遊べるルドスパス")
    ]

    // MARK: - Alfa Romeo (2701...)

    static let alfaRomeo: [Car] = [
        Car(id: 2701, maker: "Alfa Romeo", name: "ジュリア", body: "セダン", drive: "FR",
            trans: "8AT", transType: .at, power: 280, disp: "2.0L Turbo", fuel: "12.4",
            price: 799, colorHex: "#B71C1C", ev: false, tag: "官能の FR セダン"),
        Car(id: 2702, maker: "Alfa Romeo", name: "ステルヴィオ", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 280, disp: "2.0L Turbo", fuel: "11.5",
            price: 869, colorHex: "#C62828", ev: false, tag: "峠を走る SUV"),
        Car(id: 2703, maker: "Alfa Romeo", name: "トナーレ", body: "SUV", drive: "FF",
            trans: "7AT", transType: .at, power: 160, disp: "1.5L Turbo MHEV", fuel: "15.3",
            price: 589, colorHex: "#D32F2F", ev: false, tag: "新世代アルファ"),
        Car(id: 2704, maker: "Alfa Romeo", name: "ジュニア", body: "SUV", drive: "FF",
            trans: "AT", transType: .at, power: 156, disp: "EV 54kWh", fuel: "航続 470km",
            price: 595, colorHex: "#E53935", ev: true, tag: "アルファ初の EV")
    ]

    // MARK: - Smart (3701...)

    static let smart: [Car] = [
        Car(id: 3701, maker: "Smart", name: "#1", body: "SUV", drive: "RWD",
            trans: "AT", transType: .at, power: 272, disp: "EV 66kWh", fuel: "航続 555km",
            price: 599, colorHex: "#37474F", ev: true, tag: "新生スマート"),
        Car(id: 3702, maker: "Smart", name: "#3", body: "SUV", drive: "RWD",
            trans: "AT", transType: .at, power: 272, disp: "EV 66kWh", fuel: "航続 570km",
            price: 649, colorHex: "#455A64", ev: true, tag: "クーペフォルム EV")
    ]

    // MARK: - Alpine (3601...)

    static let alpine: [Car] = [
        Car(id: 3601, maker: "Alpine", name: "A110", body: "クーペ", drive: "MR",
            trans: "7AT", transType: .at, power: 252, disp: "1.8L Turbo", fuel: "12.6",
            price: 899, colorHex: "#1565C0", ev: false, tag: "軽量ミッドシップ")
    ]
}
