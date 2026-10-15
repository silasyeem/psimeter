/*
THESIS: Air read off a real instrument; refuses the band-coloured number tile every AQ widget ships.
OWN-WORLD: Gunmetal plate, knurled brass bezel, grained-silver dial by day, black lacquer with radium lume by night, blued-steel needle, black roller-counter wheels, one five-segment vitreous enamel arc where only the current band is saturated.
STORY: Glance, read the exact 24h PSI for your region and the WAQI AQI beneath it, see the band by needle position, see how fresh it is.
FIRST VIEWPORT: Wide roller counter (PSI) across the dial centre, 160-degree band arc and needle above, smaller AQI counter below, time under it, regional PSIs engraved on the bezel at N/E/S/W.
FORM: Brass Aneroid, grounded list position 4, seed 95d203dd. Layout C approved.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
*/

import SwiftUI
import WidgetKit

struct InstrumentView: View {
    let reading: Reading
    let finish: Finish

    var body: some View {
        GeometryReader { proxy in
            let g = DialGeometry(side: min(proxy.size.width, proxy.size.height))
            let palette = Palette.of(finish)
            ZStack(alignment: .topLeading) {
                DialPrint(reading: reading, palette: palette, g: g)
                RollerCounter(value: reading.psi, centre: g.psiCounter, height: g.psiCounterHeight, palette: palette, u: g.u)
                RollerCounter(value: reading.aqi, centre: g.aqiCounter, height: g.aqiCounterHeight, palette: palette, u: g.u)
                Needle(value: reading.needleValue, palette: palette, g: g)
                    .widgetAccentable()
                Hub(palette: palette, g: g)
                Crystal(face: palette.face, g: g)
            }
            .frame(width: g.side, height: g.side)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reading.spoken)
    }
}

struct DialGeometry {
    let side: CGFloat
    var u: CGFloat { side / 170 }
    var type: CGFloat { max(9, 9 * u) }

    var centre: CGPoint { CGPoint(x: 0.498 * side, y: 0.480 * side) }
    var radius: CGFloat { 0.389 * side }
    var ring: CGFloat { 0.4165 * side }
    var ringOuter: CGFloat { 0.452 * side }

    var arcCentre: CGPoint { CGPoint(x: centre.x, y: 78.6 * u) }
    var arcRadius: CGFloat { 45.4 * u }
    var band: CGFloat { 5.6 * u }
    var bandEdge: CGFloat { arcRadius + band / 2 }
    var tickEnd: CGFloat { bandEdge + 4.2 * u }
    var hub: CGPoint { CGPoint(x: centre.x, y: 55 * u) }
    var hubRadius: CGFloat { 4.8 * u }

    var psiLabel: CGPoint { CGPoint(x: centre.x, y: 65.3 * u) }
    var psiCounter: CGPoint { CGPoint(x: centre.x, y: 89.35 * u) }
    var psiCounterHeight: CGFloat { 38.35 * u }
    var aqiLabel: CGPoint { CGPoint(x: centre.x, y: 113.4 * u) }
    var aqiCounter: CGPoint { CGPoint(x: centre.x, y: 125.22 * u) }
    var aqiCounterHeight: CGFloat { 13.89 * u }
    var timeRadius: CGFloat { 58.05 * u }

    func angle(_ value: Double) -> Double {
        let span = Double(Scale.psiDial.upperBound - Scale.psiDial.lowerBound)
        return (153 - 126 * (value - Double(Scale.psiDial.lowerBound)) / span) * .pi / 180
    }

    func valueSpan(_ length: CGFloat, at r: CGFloat) -> Double {
        Double(length / r) * 180 / .pi * Double(Scale.psiDial.upperBound - Scale.psiDial.lowerBound) / 126
    }

    func point(_ value: Double, r: CGFloat) -> CGPoint {
        let a = angle(value)
        return CGPoint(x: arcCentre.x + r * cos(a), y: arcCentre.y - r * sin(a))
    }

    func sector(_ from: Double, _ to: Double, inner: CGFloat, outer: CGFloat) -> Path {
        let steps = max(8, Int((to - from) / 2))
        var path = Path()
        for i in 0...steps {
            let p = point(from + (to - from) * Double(i) / Double(steps), r: outer)
            i == 0 ? path.move(to: p) : path.addLine(to: p)
        }
        for i in (0...steps).reversed() {
            path.addLine(to: point(from + (to - from) * Double(i) / Double(steps), r: inner))
        }
        path.closeSubpath()
        return path
    }

    func circle(_ r: CGFloat, at c: CGPoint? = nil) -> Path {
        let c = c ?? centre
        return Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
    }
}

private struct DialPrint: View {
    let reading: Reading
    let palette: Palette
    let g: DialGeometry

    var body: some View {
        Canvas { ctx, _ in
            face(&ctx)
            enamel(&ctx)
            ticks(&ctx)
            numerals(&ctx)
            labels(&ctx)
            bezel(&ctx)
        }
        .frame(width: g.side, height: g.side)
    }

    private func engraved(_ s: String, weight: Font.Weight = .medium, color: Color? = nil) -> Text {
        Text(s)
            .font(.system(size: g.type, weight: weight, design: .serif))
            .tracking(0.1 * g.u)
            .foregroundStyle(color ?? palette.ink)
    }

    private func inscribe(_ text: Text, at p: CGPoint, in ctx: inout GraphicsContext) {
        ctx.drawLayer { layer in
            if let glow = palette.glow {
                layer.addFilter(.shadow(color: glow, radius: 1.6 * g.u))
            }
            layer.draw(text, at: p, anchor: .center)
        }
    }

    private func face(_ ctx: inout GraphicsContext) {
        let dial = g.circle(g.radius)
        let box = dial.boundingRect
        switch palette.face {
        case .silver:
            ctx.drawLayer { layer in
                layer.clip(to: dial)
                layer.draw(Image("DialSilver").resizable(), in: box)
                layer.fill(dial, with: .radialGradient(
                    Gradient(stops: [
                        .init(color: .white.opacity(0.16), location: 0),
                        .init(color: .clear, location: 0.55),
                        .init(color: .black.opacity(0.14), location: 1),
                    ]),
                    center: CGPoint(x: g.centre.x - 0.25 * g.radius, y: g.centre.y - 0.35 * g.radius),
                    startRadius: 0, endRadius: 1.35 * g.radius))
            }
        case .lacquer:
            ctx.fill(dial, with: .radialGradient(
                Gradient(colors: [Color(white: 0.11), Color(white: 0.05), Color(white: 0.015)]),
                center: CGPoint(x: g.centre.x - 0.2 * g.radius, y: g.centre.y - 0.3 * g.radius),
                startRadius: 0, endRadius: 1.3 * g.radius))
        case .open:
            ctx.stroke(g.circle(g.ringOuter), with: .color(.white.opacity(0.45)), lineWidth: 0.8 * g.u)
            ctx.stroke(g.circle(g.radius), with: .color(.white.opacity(0.45)), lineWidth: 0.8 * g.u)
            return
        }
        ctx.drawLayer { layer in
            layer.clip(to: dial)
            layer.addFilter(.blur(radius: 2.4 * g.u))
            layer.stroke(g.circle(g.radius + 1.2 * g.u, at: CGPoint(x: g.centre.x - 0.6 * g.u, y: g.centre.y - 1.1 * g.u)),
                         with: .color(.black.opacity(palette.face == .silver ? 0.55 : 0.9)), lineWidth: 6 * g.u)
        }
    }

    private func enamel(_ ctx: inout GraphicsContext) {
        let current = reading.psi.map { Scale.psi.band(for: $0).range }
        let bounds: [(Double, Double, Band)] = Scale.psi.bands.map { band in
            let lo = Double(max(band.range.lowerBound == 0 ? 0 : band.range.lowerBound - 1, Scale.psiDial.lowerBound))
            let hi = Double(min(band.range.upperBound, Scale.psiDial.upperBound))
            return (lo, hi, band)
        }
        let inner = g.arcRadius - g.band / 2
        let outer = g.arcRadius + g.band / 2
        let gap = g.valueSpan(0.75 * g.u, at: g.arcRadius)
        for (lo, hi, band) in bounds {
            let path = g.sector(lo == 0 ? lo : lo + gap, hi == 400 ? hi : hi - gap, inner: inner, outer: outer)
            let isCurrent = band.range == current
            let color = isCurrent ? palette.currentEnamel(band.enamel) : palette.mutedEnamel(band.enamel)
            ctx.fill(path, with: .color(color))
            guard palette.face != .open else { continue }
            ctx.fill(path, with: .radialGradient(
                Gradient(stops: [
                    .init(color: .black.opacity(0.18), location: 0),
                    .init(color: .clear, location: 0.45),
                    .init(color: .white.opacity(isCurrent ? 0.38 : 0.22), location: 0.92),
                    .init(color: .white.opacity(0.05), location: 1),
                ]),
                center: g.arcCentre, startRadius: inner, endRadius: outer))
            ctx.stroke(path, with: .color(.black.opacity(palette.face == .silver ? 0.22 : 0.5)), lineWidth: 0.3 * g.u)
        }
    }

    private static let majors: Set<Int> = [0, 50, 100, 200, 300, 400]

    private func ticks(_ ctx: inout GraphicsContext) {
        let start = g.bandEdge + 0.7 * g.u
        let major = g.tickEnd - start
        ctx.drawLayer { layer in
            if let glow = palette.glow {
                layer.addFilter(.shadow(color: glow, radius: 1.2 * g.u))
            }
            for value in stride(from: 0, through: 400, by: 25) {
                let isMajor = Self.majors.contains(value)
                var tick = Path()
                tick.move(to: g.point(Double(value), r: start))
                tick.addLine(to: g.point(Double(value), r: start + (isMajor ? major : major * 2 / 3)))
                layer.stroke(tick, with: .color(palette.ink), style: StrokeStyle(lineWidth: (isMajor ? 1.1 : 0.8) * g.u, lineCap: .butt))
            }
        }
    }

    private func numerals(_ ctx: inout GraphicsContext) {
        for value in [0, 100, 200, 300, 400] {
            let p = g.point(Double(value), r: g.tickEnd + 1.2 * g.u + 0.36 * g.type)
            ctx.drawLayer { layer in
                layer.translateBy(x: p.x, y: p.y)
                layer.rotate(by: .radians(.pi / 2 - g.angle(Double(value))))
                if let glow = palette.glow {
                    layer.addFilter(.shadow(color: glow, radius: 1.6 * g.u))
                }
                layer.draw(engraved("\(value)"), at: .zero, anchor: .center)
            }
        }
    }

    private func labels(_ ctx: inout GraphicsContext) {
        inscribe(engraved(reading.psiLabel), at: g.psiLabel, in: &ctx)
        inscribe(engraved(reading.aqiLabel), at: g.aqiLabel, in: &ctx)
        switch reading.time {
        case .none:
            break
        case .fresh(let clock):
            curve(clock, color: palette.ink, glow: palette.glow, in: &ctx)
        case .stale(let mark):
            curve(mark, color: palette.stale, glow: nil, in: &ctx)
        }
    }

    private func curve(_ s: String, color: Color, glow: Color?, in ctx: inout GraphicsContext) {
        let glyphs = s.map { ctx.resolve(engraved(String($0), color: color)) }
        let advances = glyphs.map { $0.measure(in: CGSize(width: 200, height: 200)).width + 0.1 * g.u }
        var along = -advances.reduce(0, +) / 2
        for (glyph, advance) in zip(glyphs, advances) {
            let theta = .pi / 2 - (along + advance / 2) / g.timeRadius
            let p = CGPoint(x: g.centre.x + g.timeRadius * cos(theta), y: g.centre.y + g.timeRadius * sin(theta))
            ctx.drawLayer { layer in
                layer.translateBy(x: p.x, y: p.y)
                layer.rotate(by: .radians(theta - .pi / 2))
                if let glow {
                    layer.addFilter(.shadow(color: glow, radius: 1.6 * g.u))
                }
                layer.draw(glyph, at: .zero, anchor: .center)
            }
            along += advance
        }
    }

    private func bezel(_ ctx: inout GraphicsContext) {
        let marks: [(Region, String, CGPoint, Double)] = [
            (.north, "N", CGPoint(x: g.centre.x, y: g.centre.y - g.ring), 0),
            (.south, "S", CGPoint(x: g.centre.x, y: g.centre.y + g.ring), 0),
            (.west, "W", CGPoint(x: g.centre.x - g.ring, y: g.centre.y), -.pi / 2),
            (.east, "E", CGPoint(x: g.centre.x + g.ring, y: g.centre.y), .pi / 2),
        ]
        for (region, letter, p, rotation) in marks {
            let label = reading.bezel[region].map { "\(letter) \($0)" } ?? letter
            ctx.drawLayer { layer in
                layer.translateBy(x: p.x, y: p.y)
                layer.rotate(by: .radians(rotation))
                if let relief = palette.bezelRelief {
                    layer.draw(engraved(label, weight: .semibold, color: relief), at: CGPoint(x: 0, y: 0.55 * g.u), anchor: .center)
                }
                if let glow = palette.glow {
                    layer.addFilter(.shadow(color: glow, radius: 1.6 * g.u))
                }
                layer.draw(engraved(label, weight: .semibold, color: palette.bezelInk), at: .zero, anchor: .center)
            }
        }
    }
}

private struct Needle: View {
    let value: Int
    let palette: Palette
    let g: DialGeometry

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var reference: CGFloat { 40 * g.u }

    var body: some View {
        let tip = g.point(Double(value), r: g.tickEnd - 0.8 * g.u)
        let dx = tip.x - g.hub.x
        let dy = tip.y - g.hub.y
        let pivot = UnitPoint(x: g.hub.x / g.side, y: g.hub.y / g.side)
        blade
            .scaleEffect(x: 1, y: hypot(dx, dy) / reference, anchor: pivot)
            .rotationEffect(.radians(atan2(dx, -dy)), anchor: pivot)
            .shadow(color: .black.opacity(palette.face == .silver ? 0.38 : palette.face == .lacquer ? 0.6 : 0),
                    radius: 0.9 * g.u, x: 0.9 * g.u, y: 1.4 * g.u)
            .animation(reduceMotion ? nil : .smooth(duration: 1.2), value: value)
    }

    private var blade: some View {
        Canvas { ctx, _ in
            let base = g.hub
            let length = reference
            func at(_ along: CGFloat, _ across: CGFloat) -> CGPoint {
                CGPoint(x: base.x + across, y: base.y - along)
            }
            let root = 1.9 * g.u
            let point = 0.36 * g.u
            var shape = Path()
            shape.move(to: at(-3 * g.u, 1.0 * g.u))
            shape.addLine(to: at(0, root))
            shape.addLine(to: at(length, point))
            shape.addLine(to: at(length, -point))
            shape.addLine(to: at(0, -root))
            shape.addLine(to: at(-3 * g.u, -1.0 * g.u))
            shape.closeSubpath()
            ctx.fill(shape, with: .linearGradient(
                Gradient(colors: [palette.needleBase, palette.needleTip]),
                startPoint: base, endPoint: at(length, 0)))

            if let from = palette.needleLumeFrom {
                var lume = Path()
                let start = length * from
                let width = root + (point - root) * from
                lume.move(to: at(start, width * 0.8))
                lume.addLine(to: at(length, point * 0.8))
                lume.addLine(to: at(length, -point * 0.8))
                lume.addLine(to: at(start, -width * 0.8))
                lume.closeSubpath()
                ctx.drawLayer { layer in
                    layer.addFilter(.shadow(color: Palette.lume.opacity(0.85), radius: 2 * g.u))
                    layer.fill(lume, with: .color(Palette.lume))
                }
            } else if palette.face == .silver {
                var bevel = Path()
                bevel.move(to: at(0, root))
                bevel.addLine(to: at(length, point))
                bevel.addLine(to: at(length, 0))
                bevel.addLine(to: at(0, 0))
                bevel.closeSubpath()
                ctx.fill(bevel, with: .color(.white.opacity(0.22)))
            }
        }
        .frame(width: g.side, height: g.side)
    }
}

private struct Hub: View {
    let palette: Palette
    let g: DialGeometry

    var body: some View {
        Canvas { ctx, _ in
            let r = g.hubRadius
            let c = g.hub
            let cap = g.circle(r, at: c)
            if palette.face == .open {
                ctx.stroke(cap, with: .color(.white.opacity(0.85)), lineWidth: 0.8 * g.u)
                return
            }
            let tone = palette.face == .lacquer ? 0.78 : 1.0
            func brass(_ red: Double, _ green: Double, _ blue: Double) -> Color { Color(red: red * tone, green: green * tone, blue: blue * tone) }
            ctx.drawLayer { layer in
                layer.addFilter(.blur(radius: 1 * g.u))
                layer.fill(g.circle(r, at: CGPoint(x: c.x + 0.7 * g.u, y: c.y + 1.2 * g.u)), with: .color(.black.opacity(0.5)))
            }
            ctx.fill(cap, with: .linearGradient(
                Gradient(colors: [brass(0.93, 0.80, 0.50), brass(0.78, 0.62, 0.31), brass(0.55, 0.41, 0.18)]),
                startPoint: CGPoint(x: c.x - r, y: c.y - r), endPoint: CGPoint(x: c.x + r, y: c.y + r)))
            var ring = r * 0.9
            var light = true
            while ring > r * 0.14 {
                ctx.stroke(g.circle(ring, at: c), with: .color(light ? .white.opacity(0.13) : .black.opacity(0.10)), lineWidth: 0.22 * g.u)
                ring -= 0.3 * g.u
                light.toggle()
            }
            ctx.stroke(g.circle(r - 0.4 * g.u, at: c), with: .linearGradient(
                Gradient(colors: [.white.opacity(0.45), .black.opacity(0.35)]),
                startPoint: CGPoint(x: c.x - r, y: c.y - r), endPoint: CGPoint(x: c.x + r, y: c.y + r)),
                lineWidth: 0.7 * g.u)
            ctx.stroke(cap, with: .color(.black.opacity(0.45)), lineWidth: 0.35 * g.u)
            ctx.fill(g.circle(0.55 * g.u, at: c), with: .color(brass(0.45, 0.33, 0.14)))
        }
        .frame(width: g.side, height: g.side)
    }
}

private struct Crystal: View {
    let face: Palette.Face
    let g: DialGeometry

    var body: some View {
        Canvas { ctx, _ in
            guard face != .open else { return }
            let day = face == .silver
            let dial = g.circle(g.radius)
            ctx.clip(to: dial)

            ctx.drawLayer { layer in
                layer.addFilter(.blur(radius: 1.6 * g.u))
                layer.stroke(g.circle(g.radius - 2.6 * g.u), with: .linearGradient(
                    Gradient(colors: day ? [.black.opacity(0.24), .black.opacity(0.02)] : [.white.opacity(0.09), .white.opacity(0.02)]),
                    startPoint: CGPoint(x: g.centre.x, y: g.centre.y - g.radius),
                    endPoint: CGPoint(x: g.centre.x, y: g.centre.y + g.radius)), lineWidth: 4.4 * g.u)
            }

            ctx.fill(dial, with: .radialGradient(
                Gradient(colors: [.white.opacity(day ? 0.16 : 0.1), .clear]),
                center: CGPoint(x: g.centre.x - 0.5 * g.radius, y: g.centre.y - 0.6 * g.radius),
                startRadius: 0, endRadius: 0.75 * g.radius))

            var crescent = Path()
            crescent.addPath(g.circle(g.radius - 0.9 * g.u))
            crescent.addPath(g.circle(0.972 * g.radius, at: CGPoint(x: g.centre.x + 0.034 * g.radius, y: g.centre.y + 0.046 * g.radius)))
            ctx.drawLayer { layer in
                layer.addFilter(.blur(radius: 0.7 * g.u))
                layer.fill(crescent, with: .linearGradient(
                    Gradient(stops: [
                        .init(color: .white.opacity(day ? 0.85 : 0.82), location: 0),
                        .init(color: .white.opacity(day ? 0.35 : 0.32), location: 0.4),
                        .init(color: .clear, location: 0.75),
                    ]),
                    startPoint: CGPoint(x: g.centre.x - 0.72 * g.radius, y: g.centre.y - 0.72 * g.radius),
                    endPoint: CGPoint(x: g.centre.x + 0.1 * g.radius, y: g.centre.y + 0.1 * g.radius)),
                    style: FillStyle(eoFill: true))
            }
        }
        .frame(width: g.side, height: g.side)
        .allowsHitTesting(false)
    }
}
