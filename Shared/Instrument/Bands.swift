import SwiftUI

struct Band: Sendable {
    let name: String
    let range: ClosedRange<Int>
    let enamel: Color
}

enum Scale: Sendable {
    case psi, aqi

    static let psiDial = 0...400

    var bands: [Band] {
        switch self {
        case .psi: Self.psiBands
        case .aqi: Self.aqiBands
        }
    }

    func band(for value: Int) -> Band {
        bands.last { value >= $0.range.lowerBound } ?? bands[0]
    }

    private static let psiBands: [Band] = [
        Band(name: "Good", range: 0...50, enamel: Enamel.green),
        Band(name: "Moderate", range: 51...100, enamel: Enamel.blue),
        Band(name: "Unhealthy", range: 101...200, enamel: Enamel.vermilion),
        Band(name: "Very Unhealthy", range: 201...300, enamel: Enamel.oxblood),
        Band(name: "Hazardous", range: 301...Int.max, enamel: Enamel.maroon),
    ]

    private static let aqiBands: [Band] = [
        Band(name: "Good", range: 0...50, enamel: Enamel.green),
        Band(name: "Moderate", range: 51...100, enamel: Enamel.ochre),
        Band(name: "Unhealthy for Sensitive Groups", range: 101...150, enamel: Enamel.amber),
        Band(name: "Unhealthy", range: 151...200, enamel: Enamel.vermilion),
        Band(name: "Very Unhealthy", range: 201...300, enamel: Enamel.oxblood),
        Band(name: "Hazardous", range: 301...Int.max, enamel: Enamel.maroon),
    ]
}

enum Enamel {
    static let green = Color(red: 0.20, green: 0.55, blue: 0.27)
    static let blue = Color(red: 0.19, green: 0.42, blue: 0.74)
    static let vermilion = Color(red: 0.92, green: 0.29, blue: 0.13)
    static let oxblood = Color(red: 0.55, green: 0.17, blue: 0.16)
    static let maroon = Color(red: 0.43, green: 0.11, blue: 0.17)
    static let ochre = Color(red: 0.85, green: 0.66, blue: 0.16)
    static let amber = Color(red: 0.90, green: 0.47, blue: 0.13)
}
