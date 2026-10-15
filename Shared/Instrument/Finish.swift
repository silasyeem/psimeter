import SwiftUI
import WidgetKit

enum Finish: Sendable {
    case day, night, accented

    init(colorScheme: ColorScheme, renderingMode: WidgetRenderingMode) {
        if renderingMode == .accented {
            self = .accented
        } else {
            self = colorScheme == .dark ? .night : .day
        }
    }
}
