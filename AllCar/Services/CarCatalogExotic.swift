import Foundation

/// スーパーカー・ラグジュアリーブランド（Ferrari / Lamborghini / McLaren / Bentley /
/// Rolls-Royce / Aston Martin / Maserati / Lotus）。
extension CarCatalog {

    // MARK: - Ferrari (2001...)

    static let ferrari: [Car] = [
        Car(id: 2001, maker: "Ferrari", name: "296 GTB", body: "クーペ", drive: "MR",
            trans: "8AT", transType: .at, power: 830, disp: "3.0L V6 Turbo PHEV", fuel: "6.4",
            price: 3678, colorHex: "#D50000", ev: false, tag: "V6 ハイブリッド跳ね馬"),
        Car(id: 2002, maker: "Ferrari", name: "296 GTS", body: "オープン", drive: "MR",
            trans: "8AT", transType: .at, power: 830, disp: "3.0L V6 Turbo PHEV", fuel: "6.4",
            price: 4046, colorHex: "#C62828", ev: false, tag: "オープン跳ね馬"),
        Car(id: 2003, maker: "Ferrari", name: "SF90 ストラダーレ", body: "クーペ", drive: "AWD",
            trans: "8AT", transType: .at, power: 1000, disp: "4.0L V8 Turbo PHEV", fuel: "6.1",
            price: 6674, colorHex: "#B71C1C", ev: false, tag: "1000 馬力の市販車"),
        Car(id: 2004, maker: "Ferrari", name: "12チリンドリ", body: "クーペ", drive: "FR",
            trans: "8AT", transType: .at, power: 830, disp: "6.5L V12 NA", fuel: "5.9",
            price: 5900, colorHex: "#E53935", ev: false, tag: "V12 の継承者"),
        Car(id: 2005, maker: "Ferrari", name: "ローマ スパイダー", body: "オープン", drive: "FR",
            trans: "8AT", transType: .at, power: 620, disp: "3.9L V8 Turbo", fuel: "8.2",
            price: 3200, colorHex: "#D32F2F", ev: false, tag: "甘美な生活"),
        Car(id: 2006, maker: "Ferrari", name: "プロサングエ", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 725, disp: "6.5L V12 NA", fuel: "6.0",
            price: 4700, colorHex: "#C62828", ev: false, tag: "フェラーリ初の 4 ドア")
    ]

    // MARK: - Lamborghini (2101...)

    static let lamborghini: [Car] = [
        Car(id: 2101, maker: "Lamborghini", name: "レヴエルト", body: "クーペ", drive: "AWD",
            trans: "8AT", transType: .at, power: 1015, disp: "6.5L V12 PHEV", fuel: "5.8",
            price: 6567, colorHex: "#F9A825", ev: false, tag: "V12 ハイブリッド猛牛"),
        Car(id: 2102, maker: "Lamborghini", name: "テメラリオ", body: "クーペ", drive: "AWD",
            trans: "8AT", transType: .at, power: 920, disp: "4.0L V8 Turbo PHEV", fuel: "6.5",
            price: 4600, colorHex: "#F57F17", ev: false, tag: "ウラカンの後継"),
        Car(id: 2103, maker: "Lamborghini", name: "ウルス SE", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 800, disp: "4.0L V8 Turbo PHEV", fuel: "7.5",
            price: 3550, colorHex: "#FBC02D", ev: false, tag: "スーパー SUV")
    ]

    // MARK: - McLaren (2201...)

    static let mclaren: [Car] = [
        Car(id: 2201, maker: "McLaren", name: "アルトゥーラ", body: "クーペ", drive: "MR",
            trans: "8AT", transType: .at, power: 700, disp: "3.0L V6 Turbo PHEV", fuel: "7.1",
            price: 3070, colorHex: "#FF6F00", ev: false, tag: "次世代ハイブリッド"),
        Car(id: 2202, maker: "McLaren", name: "750S", body: "クーペ", drive: "MR",
            trans: "7AT", transType: .at, power: 750, disp: "4.0L V8 Turbo", fuel: "7.2",
            price: 4230, colorHex: "#F57C00", ev: false, tag: "軽さこそ正義"),
        Car(id: 2203, maker: "McLaren", name: "750S スパイダー", body: "オープン", drive: "MR",
            trans: "7AT", transType: .at, power: 750, disp: "4.0L V8 Turbo", fuel: "7.2",
            price: 4650, colorHex: "#EF6C00", ev: false, tag: "オープンスーパーカー"),
        Car(id: 2204, maker: "McLaren", name: "GTS", body: "クーペ", drive: "MR",
            trans: "7AT", transType: .at, power: 635, disp: "4.0L V8 Turbo", fuel: "7.5",
            price: 3450, colorHex: "#E65100", ev: false, tag: "毎日乗れるマクラーレン")
    ]

    // MARK: - Bentley (2301...)

    static let bentley: [Car] = [
        Car(id: 2301, maker: "Bentley", name: "コンチネンタル GT", body: "クーペ", drive: "AWD",
            trans: "8AT", transType: .at, power: 782, disp: "4.0L V8 PHEV", fuel: "8.0",
            price: 4200, colorHex: "#1B5E20", ev: false, tag: "グランドツアラーの頂点"),
        Car(id: 2302, maker: "Bentley", name: "コンチネンタル GTC", body: "オープン", drive: "AWD",
            trans: "8AT", transType: .at, power: 782, disp: "4.0L V8 PHEV", fuel: "7.8",
            price: 4600, colorHex: "#2E7D32", ev: false, tag: "オープン GT"),
        Car(id: 2303, maker: "Bentley", name: "フライングスパー", body: "セダン", drive: "AWD",
            trans: "8AT", transType: .at, power: 782, disp: "4.0L V8 PHEV", fuel: "7.9",
            price: 4100, colorHex: "#33691E", ev: false, tag: "駆るためのリムジン"),
        Car(id: 2304, maker: "Bentley", name: "ベンテイガ", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 550, disp: "4.0L V8 Turbo", fuel: "8.2",
            price: 3000, colorHex: "#388E3C", ev: false, tag: "ラグジュアリー SUV")
    ]

    // MARK: - Rolls-Royce (2401...)

    static let rollsRoyce: [Car] = [
        Car(id: 2401, maker: "Rolls-Royce", name: "ゴースト", body: "セダン", drive: "AWD",
            trans: "8AT", transType: .at, power: 571, disp: "6.75L V12 Turbo", fuel: "6.2",
            price: 4700, colorHex: "#4A148C", ev: false, tag: "静寂の極み"),
        Car(id: 2402, maker: "Rolls-Royce", name: "ファントム", body: "セダン", drive: "AWD",
            trans: "8AT", transType: .at, power: 571, disp: "6.75L V12 Turbo", fuel: "6.0",
            price: 6600, colorHex: "#311B92", ev: false, tag: "自動車の最高峰"),
        Car(id: 2403, maker: "Rolls-Royce", name: "カリナン", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 571, disp: "6.75L V12 Turbo", fuel: "5.8",
            price: 5300, colorHex: "#512DA8", ev: false, tag: "ロールスの SUV"),
        Car(id: 2404, maker: "Rolls-Royce", name: "スペクター", body: "クーペ", drive: "AWD",
            trans: "AT", transType: .at, power: 585, disp: "EV 102kWh", fuel: "航続 530km",
            price: 5900, colorHex: "#673AB7", ev: true, tag: "電動ロールス")
    ]

    // MARK: - Aston Martin (2501...)

    static let astonMartin: [Car] = [
        Car(id: 2501, maker: "Aston Martin", name: "ヴァンテージ", body: "クーペ", drive: "FR",
            trans: "8AT", transType: .at, power: 665, disp: "4.0L V8 Turbo", fuel: "8.5",
            price: 2690, colorHex: "#004D40", ev: false, tag: "英国の獰猛"),
        Car(id: 2502, maker: "Aston Martin", name: "DB12", body: "クーペ", drive: "FR",
            trans: "8AT", transType: .at, power: 680, disp: "4.0L V8 Turbo", fuel: "8.3",
            price: 2990, colorHex: "#00695C", ev: false, tag: "スーパーツアラー"),
        Car(id: 2503, maker: "Aston Martin", name: "ヴァンキッシュ", body: "クーペ", drive: "FR",
            trans: "8AT", transType: .at, power: 835, disp: "5.2L V12 Turbo", fuel: "7.0",
            price: 4600, colorHex: "#00796B", ev: false, tag: "V12 の旗艦"),
        Car(id: 2504, maker: "Aston Martin", name: "DBX707", body: "SUV", drive: "AWD",
            trans: "9AT", transType: .at, power: 707, disp: "4.0L V8 Turbo", fuel: "7.8",
            price: 2980, colorHex: "#009688", ev: false, tag: "最速級 SUV")
    ]

    // MARK: - Maserati (2601...)

    static let maserati: [Car] = [
        Car(id: 2601, maker: "Maserati", name: "MC20", body: "クーペ", drive: "MR",
            trans: "8AT", transType: .at, power: 630, disp: "3.0L V6 Turbo", fuel: "9.0",
            price: 3060, colorHex: "#01579B", ev: false, tag: "ネットゥーノの咆哮"),
        Car(id: 2602, maker: "Maserati", name: "グラントゥーリズモ", body: "クーペ", drive: "AWD",
            trans: "8AT", transType: .at, power: 490, disp: "3.0L V6 Turbo", fuel: "9.5",
            price: 2300, colorHex: "#0277BD", ev: false, tag: "イタリアの GT"),
        Car(id: 2603, maker: "Maserati", name: "グランカブリオ", body: "オープン", drive: "AWD",
            trans: "8AT", transType: .at, power: 550, disp: "3.0L V6 Turbo", fuel: "9.3",
            price: 2680, colorHex: "#0288D1", ev: false, tag: "風と歌う GT"),
        Car(id: 2604, maker: "Maserati", name: "グレカーレ", body: "SUV", drive: "AWD",
            trans: "8AT", transType: .at, power: 300, disp: "2.0L Turbo MHEV", fuel: "10.5",
            price: 1099, colorHex: "#039BE5", ev: false, tag: "日常のマセラティ")
    ]

    // MARK: - Lotus (3501...)

    static let lotus: [Car] = [
        Car(id: 3501, maker: "Lotus", name: "エミーラ", body: "クーペ", drive: "MR",
            trans: "6MT", transType: .mt, power: 405, disp: "3.5L V6 SC", fuel: "9.9",
            price: 1571, colorHex: "#2E7D32", ev: false, tag: "最後の内燃ロータス"),
        Car(id: 3502, maker: "Lotus", name: "エレトレ", body: "SUV", drive: "AWD",
            trans: "AT", transType: .at, power: 612, disp: "EV 112kWh", fuel: "航続 535km",
            price: 2296, colorHex: "#388E3C", ev: true, tag: "ハイパー SUV"),
        Car(id: 3503, maker: "Lotus", name: "エメヤ", body: "セダン", drive: "AWD",
            trans: "AT", transType: .at, power: 612, disp: "EV 102kWh", fuel: "航続 500km",
            price: 2500, colorHex: "#43A047", ev: true, tag: "電動ハイパー GT")
    ]
}
