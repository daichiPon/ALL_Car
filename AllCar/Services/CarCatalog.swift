import Foundation

/// 全ブランドの車種カタログ。実データは地域別の extension ファイルに分割している。
/// - CarCatalogJapan.swift  (Toyota / Lexus / Honda / Nissan)
/// - CarCatalogJapan2.swift (Mazda / Subaru / Suzuki / Daihatsu / Mitsubishi)
/// - CarCatalogGermany.swift (Mercedes-Benz / BMW / Audi / Volkswagen / Porsche)
/// - CarCatalogEurope.swift  (MINI / Volvo / Peugeot / Renault / Fiat / Abarth / Citroën / Alfa Romeo / Smart / Alpine)
/// - CarCatalogWorld.swift   (Tesla / Hyundai / BYD / Jeep / Land Rover / Cadillac / Chevrolet)
/// - CarCatalogExotic.swift  (Ferrari / Lamborghini / McLaren / Bentley / Rolls-Royce / Aston Martin / Maserati / Lotus)
enum CarCatalog {

    /// 全車種（ブランドごとの配列を連結したもの）
    static let all: [Car] =
        toyota + lexus + honda + nissan +
        mazda + subaru + suzuki + daihatsu + mitsubishi +
        mercedesBenz + bmw + audi + volkswagen + porsche +
        mini + volvo + peugeot + renault + fiat + abarth + citroen + alfaRomeo + smart + alpine +
        tesla + hyundai + byd + jeep + landRover + cadillac + chevrolet +
        ferrari + lamborghini + mclaren + bentley + rollsRoyce + astonMartin + maserati + lotus

    /// ブランドバッジのスタイル（ロゴは商標の都合で使わず頭文字バッジで代用）
    static let brandStyles: [String: BrandBadgeStyle] = [
        "Toyota":        .init(colorHex: "#E53935", mono: "T"),
        "Lexus":         .init(colorHex: "#37474F", mono: "L"),
        "Honda":         .init(colorHex: "#E53935", mono: "H"),
        "Nissan":        .init(colorHex: "#C62828", mono: "N"),
        "Mazda":         .init(colorHex: "#1E2A44", mono: "M"),
        "Subaru":        .init(colorHex: "#1565C0", mono: "S"),
        "Suzuki":        .init(colorHex: "#1976D2", mono: "S"),
        "Daihatsu":      .init(colorHex: "#D32F2F", mono: "D"),
        "Mitsubishi":    .init(colorHex: "#B71C1C", mono: "M"),
        "Mercedes-Benz": .init(colorHex: "#263238", mono: "M"),
        "BMW":           .init(colorHex: "#1565C0", mono: "B"),
        "Audi":          .init(colorHex: "#616161", mono: "A"),
        "Volkswagen":    .init(colorHex: "#0D47A1", mono: "V"),
        "Porsche":       .init(colorHex: "#B71C1C", mono: "P"),
        "MINI":          .init(colorHex: "#212121", mono: "M"),
        "Volvo":         .init(colorHex: "#0D47A1", mono: "V"),
        "Peugeot":       .init(colorHex: "#283593", mono: "P"),
        "Renault":       .init(colorHex: "#F9A825", mono: "R"),
        "Fiat":          .init(colorHex: "#AD1457", mono: "F"),
        "Abarth":        .init(colorHex: "#C62828", mono: "A"),
        "Citroën":       .init(colorHex: "#37474F", mono: "C"),
        "Alfa Romeo":    .init(colorHex: "#B71C1C", mono: "A"),
        "Smart":         .init(colorHex: "#37474F", mono: "S"),
        "Alpine":        .init(colorHex: "#1565C0", mono: "A"),
        "Tesla":         .init(colorHex: "#C62828", mono: "T"),
        "Hyundai":       .init(colorHex: "#1A237E", mono: "H"),
        "BYD":           .init(colorHex: "#00695C", mono: "B"),
        "Jeep":          .init(colorHex: "#33691E", mono: "J"),
        "Land Rover":    .init(colorHex: "#1B5E20", mono: "L"),
        "Cadillac":      .init(colorHex: "#4527A0", mono: "C"),
        "Chevrolet":     .init(colorHex: "#F9A825", mono: "C"),
        "Ferrari":       .init(colorHex: "#D50000", mono: "F"),
        "Lamborghini":   .init(colorHex: "#F9A825", mono: "L"),
        "McLaren":       .init(colorHex: "#FF6F00", mono: "M"),
        "Bentley":       .init(colorHex: "#1B5E20", mono: "B"),
        "Rolls-Royce":   .init(colorHex: "#4A148C", mono: "R"),
        "Aston Martin":  .init(colorHex: "#004D40", mono: "A"),
        "Maserati":      .init(colorHex: "#01579B", mono: "M"),
        "Lotus":         .init(colorHex: "#2E7D32", mono: "L")
    ]
}
