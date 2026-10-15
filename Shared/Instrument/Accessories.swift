import SwiftUI
import WidgetKit

struct AccessoryCircular: View {
    let reading: Reading

    var body: some View {
        Gauge(value: Double(reading.needleValue), in: Double(Scale.psiDial.lowerBound)...Double(Scale.psiDial.upperBound)) {
            Text("PSI")
        } currentValueLabel: {
            Text(reading.psi.map(String.init) ?? "–")
        }
        .gaugeStyle(.accessoryCircular)
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reading.spoken)
    }
}

struct AccessoryRectangular: View {
    let reading: Reading

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(reading.headline)
                .font(.headline)
                .monospacedDigit()
                .widgetAccentable()
            Text(reading.detail)
                .font(.caption)
                .minimumScaleFactor(0.8)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reading.spoken)
    }
}

struct AccessoryInline: View {
    let reading: Reading

    var body: some View {
        Text(reading.headline)
            .accessibilityLabel(reading.spoken)
    }
}
