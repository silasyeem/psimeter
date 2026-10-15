import SwiftUI

struct GalleryView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            sheet(side: WidgetMetrics.smallSide(screenWidth: proxy.size.width))
        }
    }

    private func sheet(side: CGFloat) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LazyVGrid(columns: [GridItem(.fixed(side), spacing: 16), GridItem(.fixed(side), spacing: 16)], spacing: 8) {
                    ForEach(Demo.cases) { demo in
                        VStack(alignment: .leading, spacing: 3) {
                            Text("DEMO · \(demo.id)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            InstrumentTile(reading: demo.reading, finish: demo.accented ? .accented : (colorScheme == .dark ? .night : .day))
                                .frame(width: side, height: side)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                ForEach(Demo.largeCases) { demo in
                    LargeTile(demo: demo)
                        .frame(maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("DEMO · Lock Screen")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .center, spacing: 14) {
                        AccessoryCircular(reading: Demo.live.reading)
                            .frame(width: 72, height: 72)
                        AccessoryRectangular(reading: Demo.live.reading)
                            .frame(width: 172, height: 76)
                    }
                    AccessoryInline(reading: Demo.live.reading)
                    AccessoryRectangular(reading: Demo.cases[1].reading)
                        .frame(width: 172, height: 76)
                }
                .padding(16)
                .foregroundStyle(.white)
                .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .environment(\.colorScheme, .dark)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 4)
        }
        .background(Color(.systemGroupedBackground))
    }
}

enum WidgetMetrics {
    static func largeSize(screenWidth width: CGFloat) -> CGSize {
        switch width {
        case 430...: CGSize(width: 364, height: 382)
        case 414...: CGSize(width: 360, height: 379)
        case 402...: CGSize(width: 350, height: 364)
        case 390...: CGSize(width: 338, height: 354)
        case 375...: CGSize(width: 329, height: 345)
        default: CGSize(width: 292, height: 311)
        }
    }

    static func smallSide(screenWidth width: CGFloat) -> CGFloat {
        switch width {
        case 430...: return 170
        case 414...: return 169
        case 402...: return 164
        case 390...: return 158
        case 375...: return 155
        default: return 141
        }
    }
}

struct LargeTile: View {
    let demo: Demo.LargeCase
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let forcedWidth = UserDefaults.standard.double(forKey: "gallery-screen-width")
            let size = WidgetMetrics.largeSize(screenWidth: forcedWidth > 0 ? forcedWidth : proxy.size.width)
            let finish: Finish = demo.accented ? .accented : (colorScheme == .dark ? .night : .day)
            VStack(alignment: .leading, spacing: 3) {
                Text("DEMO · Large \(demo.id)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                BarographView(reading: demo.reading, trend: demo.barogram.trend, finish: finish)
                    .frame(width: size.width, height: size.height)
                    .background { LargePlate(finish: finish) }
                    .clipShape(RoundedRectangle(cornerRadius: size.width * 0.064, style: .continuous))
                    .containerShape(RoundedRectangle(cornerRadius: size.width * 0.064, style: .continuous))
            }
            .frame(width: proxy.size.width)
        }
        .frame(height: 382 + 20)
    }
}

struct LargeGalleryView: View {
    let state: String

    var body: some View {
        VStack {
            LargeTile(demo: Demo.largeCases.first { $0.id == state } ?? Demo.largeCases[0])
            Spacer()
        }
        .padding(.top, 8)
        .background(Color(.systemGroupedBackground))
    }
}
