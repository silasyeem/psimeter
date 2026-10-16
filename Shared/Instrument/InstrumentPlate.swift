import SwiftUI

struct Plate: View {
    let finish: Finish
    var wear: Wear = .polished

    var body: some View {
        if let materials = Palette.of(finish, wear).materials {
            Image(materials.tile).resizable()
        } else {
            Color(red: 0.15, green: 0.16, blue: 0.19)
        }
    }
}

struct InstrumentTile: View {
    let reading: Reading
    let finish: Finish
    var wear: Wear = .polished

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            InstrumentView(reading: reading, finish: finish, wear: wear)
                .frame(width: side, height: side)
                .background { Plate(finish: finish, wear: wear) }
                .clipShape(RoundedRectangle(cornerRadius: side * 0.13, style: .continuous))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
