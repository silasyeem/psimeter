import SwiftUI

struct Palette: Sendable {
    enum Face: Sendable {
        case silver, lacquer, open
    }

    let face: Face
    var ink: Color
    let glow: Color?
    var bezelInk: Color
    var bezelRelief: Color?
    let figure: Color
    let needleBase: Color
    let needleTip: Color
    let needleLumeFrom: Double?
    var stale: Color
    var plateInk: Color
    var plateStale: Color
    let mutedEnamel: @Sendable (Color) -> Color
    let currentEnamel: @Sendable (Color) -> Color
    var materials: Materials?

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
        plateInk: Color(red: 0.91, green: 0.88, blue: 0.80),
        plateStale: Color(red: 1.0, green: 0.62, blue: 0.48),
        mutedEnamel: { $0.mix(with: Color(white: 0.5), by: 0.22) },
        currentEnamel: { $0 },
        materials: .polishedDay
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
        plateInk: lume,
        plateStale: Color(red: 1.0, green: 0.42, blue: 0.26),
        mutedEnamel: { $0.mix(with: .black, by: 0.15) },
        currentEnamel: { $0.mix(with: Color(red: 1.0, green: 0.60, blue: 0.22), by: 0.22) },
        materials: .polishedNight
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
        plateInk: Color.white.opacity(0.85),
        plateStale: .white,
        mutedEnamel: { _ in Color.white.opacity(0.16) },
        currentEnamel: { _ in Color.white.opacity(0.62) },
        materials: nil
    )

    static let agedDay: Palette = {
        var palette = day
        palette.materials = .agedDay
        palette.plateStale = Color(red: 1.0, green: 0.66, blue: 0.53)
        return palette
    }()

    static let agedNight: Palette = {
        var palette = night
        palette.materials = .agedNight
        palette.bezelInk = Color(red: 0.90, green: 1.0, blue: 0.88)
        palette.bezelRelief = Color.black.opacity(0.55)
        palette.plateStale = Color(red: 1.0, green: 0.46, blue: 0.30)
        return palette
    }()

    static func of(_ finish: Finish, _ wear: Wear = .polished) -> Palette {
        switch (finish, wear) {
        case (.day, .polished): day
        case (.night, .polished): night
        case (.day, .aged): agedDay
        case (.night, .aged): agedNight
        case (.accented, _): accented
        }
    }
}

/// The raster materials behind a finish. The accented finish is a line drawing and has none.
struct Materials: Sendable {
    let tile: String
    let dial: String?
    let plate: String
    let paper: String
    var paperBand: ClosedRange<Double> = 0...1
    let housing: String
    let pen: String
    let screw: String
    let grain: String
    let glass: Glass
    let smudge: Double
    let neighbours: Bool

    static let polishedDay = Materials(
        tile: "BezelTile", dial: "DialSilver", plate: "PlateDay", paper: "PaperDay", housing: "DrumHousing",
        pen: "PenArm", screw: "Screw", grain: "BrassGrain", glass: .reflections("DrumGlass"), smudge: 0, neighbours: false)

    static let polishedNight = Materials(
        tile: "BezelTileNight", dial: nil, plate: "PlateNight", paper: "PaperNight", housing: "DrumHousingNight",
        pen: "PenArmNight", screw: "ScrewNight", grain: "BrassGrainNight", glass: .reflections("DrumGlass"), smudge: 0, neighbours: false)

    static let agedDay = Materials(
        tile: "BezelTileAged", dial: "DialAged", plate: "PlateDayAged", paper: "PaperDayAged", paperBand: (216.0 / 840)...(624.0 / 840), housing: "DrumHousingAged",
        pen: "PenArmAged", screw: "ScrewAged", grain: "BrassGrainAged", glass: .baked("DrumGlassAgedDay"), smudge: 0.35, neighbours: true)

    static let agedNight = Materials(
        tile: "BezelTileNightAged", dial: nil, plate: "PlateNightAged", paper: "PaperNightAged", paperBand: (216.0 / 840)...(624.0 / 840), housing: "DrumHousingNightAged",
        pen: "PenArmNightAged", screw: "ScrewNightAged", grain: "BrassGrainNightAged", glass: .baked("DrumGlassAgedNight"), smudge: 0.25, neighbours: true)
}

/// `reflections` is lifted, faded and dimmed at render time; `baked` already carries all of that, plus the
/// smudge, at the drum window's size, so the barograph screens one layer in either wear.
enum Glass: Sendable {
    case reflections(String)
    case baked(String)
}
