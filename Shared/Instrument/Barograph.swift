import SwiftUI
import WidgetKit

struct BarographView: View {
    let reading: Reading
    let trend: Feed<PSITrend>
    let finish: Finish

    static let design = CGSize(width: 350, height: 364)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / Self.design.width, proxy.size.height / Self.design.height)
            face(scale: scale)
                .frame(width: Self.design.width, height: Self.design.height)
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    private func face(scale: CGFloat) -> some View {
        let palette = Palette.of(finish)
        let chart = Chart(reading: reading, trend: trend)
        let grain: Image? = switch palette.face {
        case .silver: Image("BrassGrain")
        case .lacquer: Image("BrassGrainNight")
        case .open: nil
        }
        return ZStack(alignment: .topLeading) {
            if palette.face != .open {
                Screws(night: palette.face == .lacquer)
            }
            ChartPaper(chart: chart, palette: palette, scale: scale)
            TraceInk(chart: chart, palette: palette)
            if palette.face == .silver {
                DrumShade()
            }
            if palette.face != .open {
                DrumGlass(face: palette.face)
            }
            Housing(region: reading.region, palette: palette)
            Pen(nib: chart.nib, palette: palette)
            BaseEngraving(reading: reading, palette: palette)
            RollerCounter(value: reading.psi, centre: Layout.psiCounter, height: Layout.psiCounterHeight,
                          palette: palette, u: 1, rimScale: Layout.counterRimScale, grain: grain)
            RollerCounter(value: reading.aqi, centre: Layout.aqiCounter, height: Layout.aqiCounterHeight,
                          palette: palette, u: 1, rimScale: Layout.counterRimScale, grain: grain)
        }
    }

    private var spoken: String {
        guard case .live(let trend) = trend, let first = trend.points(reading.region).first?.psi,
              let last = trend.points(reading.region).last?.psi else {
            return reading.spoken + ". 24-hour trend unavailable"
        }
        let change = last - first
        let direction = change == 0 ? "steady" : change > 0 ? "up \(change)" : "down \(-change)"
        return reading.spoken + ". Trend \(direction) over 24 hours, from \(first)"
    }
}

struct LargePlate: View {
    let finish: Finish

    var body: some View {
        switch finish {
        case .day: plate("PlateDay")
        case .night: plate("PlateNight")
        case .accented: Color(red: 0.15, green: 0.16, blue: 0.19)
        }
    }

    private func plate(_ name: String) -> some View {
        Color.clear
            .overlay { Image(name).resizable().aspectRatio(contentMode: .fill) }
            .clipped()
            .overlay { bevel }
    }

    private var bevel: some View {
        let lit = LinearGradient(stops: [
            .init(color: .white, location: 0.47),
            .init(color: .clear, location: 0.53),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
        let shaded = LinearGradient(stops: [
            .init(color: .clear, location: 0.47),
            .init(color: .white, location: 0.53),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
        return ZStack {
            ContainerRelativeShape()
                .inset(by: 0.75)
                .stroke(Color.white.opacity(finish == .night ? 0.24 : 0.42), lineWidth: 1.5)
                .mask(lit)
            ContainerRelativeShape()
                .inset(by: 0.75)
                .stroke(Color.black.opacity(0.6), lineWidth: 1.5)
                .mask(shaded)
        }
    }
}

private enum Layout {
    static let housing = CGRect(x: 7, y: 34, width: 336, height: 182)
    static let window = CGRect(
        x: housing.minX + 0.0911 * housing.width,
        y: housing.minY + 0.1406 * housing.height,
        width: (0.9095 - 0.0911) * housing.width,
        height: (0.8534 - 0.1406) * housing.height)
    static let engraving = CGPoint(x: housing.midX, y: housing.minY + 0.066 * housing.height)

    static let plot = CGRect(x: window.minX + 26, y: window.minY + 7, width: window.width - 26 - 13, height: window.height - 26)
    static let hourLabelY: CGFloat = plot.maxY + 9
    static let valueLabelX: CGFloat = plot.minX - 4
    static let penLength: CGFloat = 31
    static let glassLift: CGFloat = 12
    static let penHeight: CGFloat = penLength * 260 / 1069
    static let penNibY: CGFloat = 0.492

    static let screwDiameter: CGFloat = 17
    static let screwBore: CGFloat = screwDiameter + 3
    static let screws: [CGPoint] = [
        CGPoint(x: 26, y: 18.5), CGPoint(x: 324, y: 18.5),
        CGPoint(x: 26, y: 344), CGPoint(x: 324, y: 344),
    ]

    static let psiLegend = CGPoint(x: 121, y: 233)
    static let psiCounter = CGPoint(x: 121, y: 285.5)
    static let psiCounterHeight: CGFloat = 84
    static let aqiLegend = CGPoint(x: 281, y: 251)
    static let aqiCounter = CGPoint(x: 281, y: 286)
    static let aqiCounterHeight: CGFloat = 44
    static let counterRimScale: CGFloat = 1.9
    static let footY: CGFloat = 343
    static let footLeft: CGFloat = 46
    static let footRight: CGFloat = 304
}

private struct Chart {
    struct Mark {
        let position: CGFloat
        let label: String?
        let labelPosition: CGFloat
        let major: Bool
    }

    struct Zone {
        let rect: CGRect
        let band: Band
        let current: Bool
    }

    let trace: [CGPoint]
    let seed: UInt64
    let hours: [Mark]
    let values: [Mark]
    let zones: [Zone]
    let nib: CGPoint
    let note: String?

    init(reading: Reading, trend: Feed<PSITrend>) {
        let plot = Layout.plot
        let points: [(hour: Date, psi: Int)]
        let window: (start: Date, end: Date)?
        switch trend {
        case .live(let trend):
            points = trend.points(reading.region)
            window = (trend.start, trend.newest.hour)
            note = nil
        case .unavailable(let failure):
            points = []
            window = nil
            note = "TREND · \(failure.engraving)"
        }

        let peak = max(points.map(\.psi).max() ?? 0, reading.psi ?? 0)
        let top = [300, 400, 500, 600, 800, 1000].first { peak <= $0 - 25 } ?? 1000
        func y(_ value: Int) -> CGFloat {
            plot.maxY - CGFloat(min(max(value, 0), top)) / CGFloat(top) * plot.height
        }

        let major = top <= 400 ? 50 : 100
        let minor = top <= 400 ? 10 : 25
        values = stride(from: minor, to: top, by: minor).map { value in
            let isMajor = value % major == 0
            return Mark(position: y(value), label: isMajor ? "\(value)" : nil, labelPosition: y(value), major: isMajor)
        }

        if let window {
            let span = window.end.timeIntervalSince(window.start)
            func x(_ date: Date) -> CGFloat {
                plot.minX + CGFloat(date.timeIntervalSince(window.start) / span) * plot.width
            }
            trace = points.map { CGPoint(x: x($0.hour), y: y($0.psi)) }
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = SGT.timeZone
            hours = stride(from: 0, to: 24, by: 1).map { offset in
                let date = window.start.addingTimeInterval(TimeInterval(offset) * 3600)
                let hour = calendar.component(.hour, from: date)
                return Mark(position: x(date), label: hour % 3 == 0 ? String(format: "%02d", hour) : nil,
                            labelPosition: x(date), major: hour % 3 == 0)
            }
        } else {
            trace = []
            hours = stride(from: 0, to: 24, by: 1).map { offset in
                let x = plot.minX + CGFloat(offset) / 24 * plot.width
                return Mark(position: x, label: nil, labelPosition: x, major: offset % 3 == 0)
            }
        }

        seed = points.reduce(0xcbf2_9ce4_8422_2325 as UInt64) { hash, point in
            let mixed = (hash ^ UInt64(bitPattern: Int64(point.hour.timeIntervalSince1970))) &* 0x0000_0100_0000_01b3
            return (mixed ^ UInt64(point.psi)) &* 0x0000_0100_0000_01b3
        }

        let current = reading.band?.range
        let bounds = [0, 50, 100, 200, 300, top]
        zones = zip(Scale.psi.bands, zip(bounds, bounds.dropFirst())).compactMap { band, edges in
            guard edges.0 < edges.1 else { return nil }
            return Zone(rect: CGRect(x: plot.minX, y: y(edges.1), width: plot.width, height: y(edges.0) - y(edges.1)),
                        band: band, current: band.range == current)
        }
        nib = CGPoint(x: plot.maxX, y: y(reading.psi ?? 0))
    }
}

private struct ChartPaper: View {
    let chart: Chart
    let palette: Palette
    let scale: CGFloat

    var body: some View {
        Canvas { ctx, _ in
            let window = Path(Layout.window)
            let plot = Layout.plot
            ctx.clip(to: window)
            switch palette.face {
            case .silver: paper("PaperDay", in: &ctx)
            case .lacquer: paper("PaperNight", in: &ctx)
            case .open: break
            }

            for zone in chart.zones {
                ctx.fill(Path(zone.rect), with: .color(zoneColor(zone)))
            }

            let gridInk: Color = switch palette.face {
            case .silver: Color(red: 0.34, green: 0.40, blue: 0.54)
            case .lacquer: Palette.lume
            case .open: .white
            }
            func rule(_ from: CGPoint, _ to: CGPoint, major: Bool) {
                var line = Path()
                line.move(to: from)
                line.addLine(to: to)
                ctx.stroke(line, with: .color(gridInk.opacity(major ? 0.42 : 0.14)), lineWidth: major ? 0.6 : 0.4)
            }
            for mark in chart.values {
                rule(CGPoint(x: plot.minX, y: mark.position), CGPoint(x: plot.maxX, y: mark.position), major: mark.major)
            }
            for mark in chart.hours.dropFirst() {
                rule(CGPoint(x: mark.position, y: plot.minY), CGPoint(x: mark.position, y: plot.maxY), major: mark.major)
            }
            var axes = Path()
            axes.move(to: CGPoint(x: plot.minX, y: plot.minY))
            axes.addLine(to: CGPoint(x: plot.minX, y: plot.maxY))
            axes.addLine(to: CGPoint(x: plot.maxX, y: plot.maxY))
            ctx.stroke(axes, with: .color(gridInk.opacity(0.6)), lineWidth: 0.7)

            ctx.drawLayer { layer in
                if let glow = palette.glow {
                    layer.addFilter(.shadow(color: glow, radius: 1.2))
                }
                for mark in chart.values {
                    if let label = mark.label {
                        layer.draw(legend(label), at: CGPoint(x: Layout.valueLabelX, y: mark.labelPosition), anchor: .trailing)
                    }
                }
                for mark in chart.hours {
                    if let label = mark.label {
                        layer.draw(legend(label), at: CGPoint(x: mark.labelPosition, y: Layout.hourLabelY), anchor: .center)
                    }
                }
                if let note = chart.note {
                    layer.draw(legend(note, size: 11), at: CGPoint(x: plot.midX, y: plot.midY), anchor: .center)
                }
            }
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height)
    }

    private func paper(_ name: String, in ctx: inout GraphicsContext) {
        let side = max(Layout.window.width, Layout.window.height)
        ctx.draw(Image(name).resizable(), in: CGRect(x: Layout.window.minX, y: Layout.window.midY - side / 2, width: side, height: side))
    }

    private func zoneColor(_ zone: Chart.Zone) -> Color {
        switch palette.face {
        case .silver: zone.band.enamel.opacity(zone.current ? 0.3 : 0.12)
        case .lacquer: palette.currentEnamel(zone.band.enamel).opacity(zone.current ? 0.3 : 0.085)
        case .open: Color.white.opacity(zone.current ? 0.14 : 0.03)
        }
    }

    private func legend(_ s: String, size: CGFloat = 9.5) -> Text {
        Text(s)
            .font(.system(size: max(size, 9 / scale), weight: .medium, design: .serif))
            .foregroundStyle(palette.ink)
    }
}

private struct TraceInk: View {
    let chart: Chart
    let palette: Palette

    var body: some View {
        Canvas { ctx, _ in
            guard chart.trace.count > 1 else { return }
            ctx.clip(to: Path(Layout.window))
            switch palette.face {
            case .silver:
                let ink = Color(red: 0.15, green: 0.10, blue: 0.27)
                let line = penned(chart.trace, seed: chart.seed)
                ctx.drawLayer { layer in
                    layer.addFilter(.blur(radius: 0.5))
                    layer.stroke(line, with: .color(ink.opacity(0.28)), style: StrokeStyle(lineWidth: 2.3, lineCap: .round, lineJoin: .round))
                }
                ctx.stroke(line, with: .color(ink), style: StrokeStyle(lineWidth: 1.05, lineCap: .round, lineJoin: .round))
            case .lacquer:
                var line = Path()
                line.addLines(chart.trace)
                ctx.drawLayer { layer in
                    layer.addFilter(.shadow(color: Palette.lume.opacity(0.8), radius: 2))
                    layer.stroke(line, with: .color(Palette.lume), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
                }
            case .open:
                var line = Path()
                line.addLines(chart.trace)
                ctx.stroke(line, with: .color(palette.figure), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height)
        .widgetAccentable()
    }

    private func penned(_ points: [CGPoint], seed: UInt64) -> Path {
        var state = seed
        func wobble() -> CGFloat {
            state &+= 0x9e37_79b9_7f4a_7c15
            var z = state
            z = (z ^ (z >> 30)) &* 0xbf58_476d_1ce4_e5b9
            z = (z ^ (z >> 27)) &* 0x94d0_49bb_1331_11eb
            z ^= z >> 31
            return (CGFloat(z >> 11) / CGFloat(1 << 53) - 0.5) * 0.56
        }
        var path = Path()
        path.move(to: points[0])
        for (from, to) in zip(points, points.dropFirst()) {
            let dx = to.x - from.x
            let dy = to.y - from.y
            let length = max(hypot(dx, dy), 0.001)
            let normal = CGPoint(x: -dy / length, y: dx / length)
            let steps = max(1, Int(length / 1.3))
            for step in 1...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let offset = step == steps ? 0 : wobble()
                path.addLine(to: CGPoint(x: from.x + dx * t + normal.x * offset, y: from.y + dy * t + normal.y * offset))
            }
        }
        return path
    }
}

private struct DrumShade: View {
    var body: some View {
        Canvas { ctx, _ in
            let window = Layout.window
            func falloff(_ edge: Double) -> Gradient {
                Gradient(stops: stride(from: 0.0, through: 1.0, by: 0.0625).map { t in
                    .init(color: Color(white: edge + (1 - edge) * cos(.pi * (t - 0.5))), location: t)
                })
            }
            ctx.fill(Path(window), with: .linearGradient(falloff(0.55),
                startPoint: CGPoint(x: 0, y: window.minY), endPoint: CGPoint(x: 0, y: window.maxY)))
            ctx.blendMode = .multiply
            ctx.fill(Path(window), with: .linearGradient(falloff(0.85),
                startPoint: CGPoint(x: window.minX, y: 0), endPoint: CGPoint(x: window.maxX, y: 0)))
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height)
        .blendMode(.multiply)
        .allowsHitTesting(false)
    }
}

private struct DrumGlass: View {
    let face: Palette.Face

    var body: some View {
        Image("DrumGlass").resizable()
            .frame(width: Layout.window.width, height: Layout.window.height)
            .mask(LinearGradient(stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: 0.8),
                .init(color: .clear, location: 0.86),
            ], startPoint: .top, endPoint: .bottom))
            .offset(y: -Layout.glassLift)
            .frame(width: Layout.window.width, height: Layout.window.height, alignment: .top)
            .clipped()
            .offset(x: Layout.window.minX, y: Layout.window.minY)
            .frame(width: BarographView.design.width, height: BarographView.design.height, alignment: .topLeading)
            .opacity(face == .silver ? 0.6 : 0.45)
            .blendMode(.screen)
            .allowsHitTesting(false)
    }
}

private struct SeatedScrew: View {
    let night: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.black.opacity(0.85), .black.opacity(0.55)],
                                     center: UnitPoint(x: 0.4, y: 0.38), startRadius: 0, endRadius: Layout.screwBore / 2))
            Circle()
                .trim(from: 0.96, to: 1.0)
                .stroke(Color.white.opacity(night ? 0.14 : 0.26), lineWidth: 0.6)
                .padding(0.3)
            Circle()
                .trim(from: 0.0, to: 0.27)
                .stroke(Color.white.opacity(night ? 0.14 : 0.26), lineWidth: 0.6)
                .padding(0.3)
            Image(night ? "ScrewNight" : "Screw").resizable()
                .frame(width: Layout.screwDiameter, height: Layout.screwDiameter)
                .shadow(color: .black.opacity(0.6), radius: 0.7, x: 0.8, y: 0.8)
        }
        .frame(width: Layout.screwBore, height: Layout.screwBore)
    }
}

private struct Screws: View {
    let night: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Layout.screws.indices, id: \.self) { index in
                let centre = Layout.screws[index]
                SeatedScrew(night: night)
                    .offset(x: centre.x - Layout.screwBore / 2, y: centre.y - Layout.screwBore / 2)
            }
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height, alignment: .topLeading)
    }
}

private struct Housing: View {
    let region: Region
    let palette: Palette

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch palette.face {
            case .silver:
                Image("DrumHousing").resizable()
                    .frame(width: Layout.housing.width, height: Layout.housing.height)
                    .offset(x: Layout.housing.minX, y: Layout.housing.minY)
            case .lacquer:
                Image("DrumHousingNight").resizable()
                    .frame(width: Layout.housing.width, height: Layout.housing.height)
                    .offset(x: Layout.housing.minX, y: Layout.housing.minY)
            case .open:
                outline
            }
            Canvas { ctx, _ in engrave(&ctx) }
                .frame(width: BarographView.design.width, height: BarographView.design.height)
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height, alignment: .topLeading)
    }

    private var outline: some View {
        Canvas { ctx, _ in
            let ink = Color.white.opacity(0.5)
            ctx.stroke(Path(roundedRect: Layout.housing, cornerRadius: 6), with: .color(ink), lineWidth: 0.8)
            ctx.stroke(Path(Layout.window), with: .color(ink.opacity(0.7)), lineWidth: 0.7)
            let bar = Layout.window.minY - Layout.housing.minY
            ctx.stroke(Path(CGRect(x: Layout.housing.minX, y: Layout.housing.minY, width: Layout.housing.width, height: bar * 0.8)), with: .color(ink.opacity(0.6)), lineWidth: 0.6)
            ctx.stroke(Path(CGRect(x: Layout.housing.minX, y: Layout.housing.maxY - bar * 0.8, width: Layout.housing.width, height: bar * 0.8)), with: .color(ink.opacity(0.6)), lineWidth: 0.6)
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height)
    }

    private func engrave(_ ctx: inout GraphicsContext) {
        let label = "PSI · 24H · \(region.rawValue.uppercased())"
        let text = { (color: Color) in
            Text(label).font(.system(size: 11.5, weight: .semibold, design: .serif)).tracking(0.6).foregroundStyle(color)
        }
        if let relief = palette.bezelRelief {
            ctx.draw(text(relief), at: CGPoint(x: Layout.engraving.x, y: Layout.engraving.y + 0.6), anchor: .center)
        }
        ctx.drawLayer { layer in
            if let glow = palette.glow {
                layer.addFilter(.shadow(color: glow, radius: 1.6))
            }
            layer.draw(text(palette.bezelInk), at: Layout.engraving, anchor: .center)
        }
    }
}

private struct Pen: View {
    let nib: CGPoint
    let palette: Palette

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var height: CGFloat { Layout.penHeight }

    var body: some View {
        ZStack(alignment: .topLeading) {
            switch palette.face {
            case .silver:
                Image("PenArm").resizable().frame(width: Layout.penLength, height: height)
                    .shadow(color: .black.opacity(0.4), radius: 0.6, x: 0.3, y: 0.8)
            case .lacquer:
                Image("PenArmNight").resizable().frame(width: Layout.penLength, height: height)
                    .shadow(color: .black.opacity(0.6), radius: 0.6, x: 0.3, y: 0.8)
            case .open:
                Capsule().fill(palette.figure).frame(width: Layout.penLength, height: 1.2)
                    .offset(y: (height - 1.2) / 2)
            }
        }
        .offset(x: nib.x, y: nib.y - height * Layout.penNibY)
        .frame(width: BarographView.design.width, height: BarographView.design.height, alignment: .topLeading)
        .animation(reduceMotion ? nil : .smooth(duration: 1.2), value: nib.y)
        .widgetAccentable()
    }
}

private struct BaseEngraving: View {
    let reading: Reading
    let palette: Palette

    private var fill: Color {
        switch palette.face {
        case .silver: Color(red: 0.91, green: 0.88, blue: 0.80)
        case .lacquer: Palette.lume
        case .open: palette.ink
        }
    }

    private var staleFill: Color {
        switch palette.face {
        case .silver: Color(red: 1.0, green: 0.62, blue: 0.48)
        case .lacquer, .open: palette.stale
        }
    }

    var body: some View {
        Canvas { ctx, _ in
            let psiLegend = reading.psi == nil ? reading.psiLabel : "PSI · NEA 24H"
            cut(psiLegend, at: Layout.psiLegend, anchor: .center, in: &ctx)
            cut(reading.aqiLabel, at: Layout.aqiLegend, anchor: .center, in: &ctx)
            let regions: [(Region, String)] = [(.north, "N"), (.south, "S"), (.east, "E"), (.west, "W")]
            let foot = regions.map { region, letter in reading.bezel[region].map { "\(letter) \($0)" } ?? letter }.joined(separator: "   ")
            cut(foot, at: CGPoint(x: Layout.footLeft, y: Layout.footY), anchor: .leading, in: &ctx)
            switch reading.time {
            case .none: break
            case .fresh(let clock): cut(clock, at: CGPoint(x: Layout.footRight, y: Layout.footY), anchor: .trailing, in: &ctx)
            case .stale(let mark): cut(mark, at: CGPoint(x: Layout.footRight, y: Layout.footY), anchor: .trailing, color: staleFill, glow: false, in: &ctx)
            }
        }
        .frame(width: BarographView.design.width, height: BarographView.design.height)
    }

    private func cut(_ s: String, at p: CGPoint, anchor: UnitPoint, color: Color? = nil, glow: Bool = true, in ctx: inout GraphicsContext) {
        let text = { (ink: Color) in
            Text(s).font(.system(size: 11.5, weight: .semibold, design: .serif)).tracking(0.5).foregroundStyle(ink)
        }
        if palette.face == .silver {
            ctx.draw(text(.black.opacity(0.6)), at: CGPoint(x: p.x - 0.4, y: p.y - 0.6), anchor: anchor)
        }
        ctx.drawLayer { layer in
            if glow, let halo = palette.glow {
                layer.addFilter(.shadow(color: halo, radius: 1.6))
            }
            layer.draw(text(color ?? fill), at: p, anchor: anchor)
        }
    }
}
