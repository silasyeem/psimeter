import SwiftUI

struct Palette: Sendable {
    enum Face: Sendable {
        case silver, lacquer, open
    }

    let face: Face
    let ink: Color
    let glow: Color?
    let bezelInk: Color
    let bezelRelief: Color?
    let figure: Color
    let needleBase: Color
    let needleTip: Color
    let needleLumeFrom: Double?
    let stale: Color
    let mutedEnamel: @Sendable (Color) -> Color
    let currentEnamel: @Sendable (Color) -> Color

    static let lume = Color(red: 0.80, green: 0.93, blue: 0.76)
    static let accent = Color(red: 1.0, green: 0.78, blue: 0.38)

    static let day = Palette(
        face: .silver,
        ink: Color(red: 0.10, green: 0.10, blue: 0.11),
        glow: nil,
        bezelInk: Color(red: 0.20, green: 0.13, blue: 0.04),
        bezelRelief: Color(red: 1.0, green: 0.94, blue: 0.74).opacity(0.55),
        figure: Color(red: 0.97, green: 0.97, blue: 0.95),
        needleBase: Color(red: 0.04, green: 0.12, blue: 0.27),
        needleTip: Color(red: 0.20, green: 0.48, blue: 0.86),
        needleLumeFrom: nil,
        stale: Color(red: 0.44, green: 0.094, blue: 0.04),
        mutedEnamel: { $0.mix(with: Color(white: 0.5), by: 0.22) },
        currentEnamel: { $0 }
    )

    static let night = Palette(
        face: .lacquer,
        ink: lume,
        glow: lume.opacity(0.6),
        bezelInk: lume,
        bezelRelief: nil,
        figure: lume,
        needleBase: Color(red: 0.13, green: 0.14, blue: 0.14),
        needleTip: Color(red: 0.26, green: 0.28, blue: 0.27),
        needleLumeFrom: 0.42,
        stale: Color(red: 1.0, green: 0.42, blue: 0.26),
        mutedEnamel: { $0.mix(with: .black, by: 0.15) },
        currentEnamel: { $0.mix(with: Color(red: 1.0, green: 0.60, blue: 0.22), by: 0.22) }
    )

    static let accented = Palette(
        face: .open,
        ink: Color.white.opacity(0.85),
        glow: nil,
        bezelInk: Color.white.opacity(0.85),
        bezelRelief: nil,
        figure: accent,
        needleBase: accent,
        needleTip: accent,
        needleLumeFrom: nil,
        stale: .white,
        mutedEnamel: { _ in Color.white.opacity(0.16) },
        currentEnamel: { _ in Color.white.opacity(0.62) }
    )

    static func of(_ finish: Finish) -> Palette {
        switch finish {
        case .day: day
        case .night: night
        case .accented: accented
        }
    }
}
