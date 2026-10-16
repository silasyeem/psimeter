import SwiftUI
import WidgetKit

struct RollerCounter: View {
    let value: Int?
    let centre: CGPoint
    let height: CGFloat
    let palette: Palette
    let u: CGFloat
    var rimScale: CGFloat = 1
    var grain: Image? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var rim: CGFloat { height * 0.065 * rimScale }
    private var inset: CGFloat { height * 0.015 }
    private var divider: CGFloat { max(0.8, height * 0.045) }
    private var drumHeight: CGFloat { height - 2 * (rim + inset) }
    private var drumWidth: CGFloat { drumHeight * 0.86 }
    private var width: CGFloat { Self.width(height: height, rimScale: rimScale) }

    static func width(height: CGFloat, rimScale: CGFloat = 1) -> CGFloat {
        let edge = height * 0.065 * rimScale + height * 0.015
        return 3 * ((height - 2 * edge) * 0.86) + 4 * max(0.8, height * 0.045) + 2 * edge
    }
    private var corner: CGFloat { height * 0.15 }
    private var figureSize: CGFloat { max(9, drumHeight * 0.703 / 0.712) }

    private var figures: [Int?] {
        guard let value else { return [nil, nil, nil] }
        let clamped = min(max(value, 0), 999)
        return [clamped / 100, clamped / 10 % 10, clamped % 10]
    }

    private var leadingZeros: Int {
        guard let value else { return 0 }
        return value < 10 ? 2 : value < 100 ? 1 : 0
    }

    var body: some View {
        ZStack {
            if palette.face == .open {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.7 * u)
            } else {
                frame
            }
            drums.padding(rim + inset)
        }
        .frame(width: width, height: height)
        .position(centre)
    }

    private var frame: some View {
        let night = palette.face == .lacquer
        return ZStack {
            Group {
                if let grain {
                    GrainFill(image: grain)
                        .overlay(LinearGradient(stops: [
                            .init(color: .white.opacity(0.2), location: 0),
                            .init(color: .clear, location: 0.35),
                            .init(color: .black.opacity(0.28), location: 1),
                        ], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: corner, style: .continuous).fill(Self.brass)
                }
            }
                .overlay {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(LinearGradient(colors: [.white.opacity(0.7), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom), lineWidth: 0.5 * u)
                }
            RoundedRectangle(cornerRadius: corner * 0.75, style: .continuous)
                .strokeBorder(LinearGradient(stops: [
                    .init(color: Color(red: 0.36, green: 0.25, blue: 0.09), location: 0),
                    .init(color: Color(red: 0.62, green: 0.47, blue: 0.21), location: 0.5),
                    .init(color: Color(red: 0.98, green: 0.90, blue: 0.66), location: 1),
                ], startPoint: .top, endPoint: .bottom), lineWidth: rim * 0.5)
                .overlay {
                    if night && grain != nil {
                        RoundedRectangle(cornerRadius: corner * 0.75, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.42), lineWidth: rim * 0.5)
                    }
                }
                .padding(rim * 0.5)
            RoundedRectangle(cornerRadius: corner * 0.55, style: .continuous)
                .strokeBorder(Color.black.opacity(0.7), lineWidth: 0.45 * u)
                .padding(rim - 0.2 * u)
            if night && grain == nil {
                RoundedRectangle(cornerRadius: corner, style: .continuous).fill(Color.black.opacity(0.22))
            }
        }
        .shadow(color: .black.opacity(night ? 0.8 : 0.5), radius: 1.2 * u, x: 0.3 * u, y: 1.0 * u)
    }

    private var drums: some View {
        HStack(spacing: divider) {
            ForEach(0..<3, id: \.self) { index in
                drum(figures[index], dim: index < leadingZeros)
            }
        }
        .padding(.horizontal, divider)
        .background {
            if palette.face != .open {
                Rectangle().fill(Color(red: 0.06, green: 0.05, blue: 0.03))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: corner * 0.4, style: .continuous))
        .overlay {
            if palette.face != .open {
                RoundedRectangle(cornerRadius: corner * 0.4, style: .continuous)
                    .stroke(Color.black.opacity(0.8), lineWidth: 1.6 * u)
                    .blur(radius: 1 * u)
                    .clipShape(RoundedRectangle(cornerRadius: corner * 0.4, style: .continuous))
                LinearGradient(stops: [
                    .init(color: .white.opacity(0.14), location: 0),
                    .init(color: .white.opacity(0.03), location: 0.46),
                    .init(color: .clear, location: 0.48),
                ], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: corner * 0.4, style: .continuous))
                .allowsHitTesting(false)
            }
        }
    }

    private func drum(_ figure: Int?, dim: Bool) -> some View {
        Group {
            if palette.face == .open {
                RoundedRectangle(cornerRadius: 1 * u).strokeBorder(Color.white.opacity(0.28), lineWidth: 0.5 * u)
            } else if let figure, palette.materials?.neighbours == true {
                Rectangle().fill(Self.cylinder).overlay {
                    neighbour((figure + 9) % 10, dim: dim).offset(y: -drumHeight * 0.76)
                    neighbour((figure + 1) % 10, dim: dim).offset(y: drumHeight * 0.76)
                }
            } else {
                Rectangle().fill(Self.cylinder)
            }
        }
        .overlay {
            if let figure {
                Text(String(figure))
                    .font(.custom("ArchivoBlack-Regular", fixedSize: figureSize))
                    .fixedSize()
                    .contentTransition(reduceMotion ? .opacity : .numericText(value: Double(figure)))
                    .foregroundStyle(palette.figure.opacity(dim ? 0.3 : 1))
                    .shadow(color: palette.glow ?? .clear, radius: palette.glow == nil ? 0 : 1.6 * u)
                    .widgetAccentable()
            }
        }
        .overlay {
            if palette.face != .open {
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.75), location: 0),
                    .init(color: .clear, location: 0.2),
                    .init(color: .clear, location: 0.8),
                    .init(color: .black.opacity(0.8), location: 1),
                ], startPoint: .top, endPoint: .bottom)
            }
        }
        .frame(width: drumWidth, height: drumHeight)
        .clipped()
        .animation(reduceMotion ? .easeInOut(duration: 0.3) : .smooth(duration: 0.9), value: figure)
    }

    private func neighbour(_ figure: Int, dim: Bool) -> some View {
        Text(String(figure))
            .font(.custom("ArchivoBlack-Regular", fixedSize: figureSize))
            .fixedSize()
            .contentTransition(reduceMotion ? .opacity : .numericText(value: Double(figure)))
            .foregroundStyle(palette.figure.opacity(dim ? 0.1 : 0.35))
    }

    static let brass = LinearGradient(stops: [
        .init(color: Color(red: 0.97, green: 0.88, blue: 0.62), location: 0),
        .init(color: Color(red: 0.80, green: 0.64, blue: 0.32), location: 0.3),
        .init(color: Color(red: 0.55, green: 0.40, blue: 0.16), location: 0.72),
        .init(color: Color(red: 0.78, green: 0.62, blue: 0.31), location: 1),
    ], startPoint: .top, endPoint: .bottom)

    static let cylinder = LinearGradient(stops: [
        .init(color: Color(white: 0.02), location: 0),
        .init(color: Color(white: 0.13), location: 0.16),
        .init(color: Color(white: 0.27), location: 0.38),
        .init(color: Color(white: 0.23), location: 0.58),
        .init(color: Color(white: 0.10), location: 0.85),
        .init(color: Color(white: 0.02), location: 1),
    ], startPoint: .top, endPoint: .bottom)
}

private struct GrainFill: View {
    let image: Image

    var body: some View {
        Canvas { ctx, size in
            let resolved = ctx.resolve(image)
            let strip = size.width * 44 / 896
            var y: CGFloat = 0
            var mirrored = false
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: strip)
                ctx.drawLayer { layer in
                    if mirrored {
                        layer.translateBy(x: 0, y: 2 * rect.midY)
                        layer.scaleBy(x: 1, y: -1)
                    }
                    layer.draw(resolved, in: rect)
                }
                y += strip
                mirrored.toggle()
            }
        }
    }
}
