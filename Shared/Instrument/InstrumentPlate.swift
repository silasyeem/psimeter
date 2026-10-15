import SwiftUI

struct Plate: View {
    let finish: Finish

    var body: some View {
        switch finish {
        case .day:
            Image("BezelTile").resizable()
        case .night:
            Image("BezelTileNight").resizable()
        case .accented:
            Color(red: 0.15, green: 0.16, blue: 0.19)
        }
    }
}

struct InstrumentTile: View {
    let reading: Reading
    let finish: Finish

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            InstrumentView(reading: reading, finish: finish)
                .frame(width: side, height: side)
                .background { Plate(finish: finish) }
                .clipShape(RoundedRectangle(cornerRadius: side * 0.13, style: .continuous))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
