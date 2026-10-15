import SwiftUI
import WidgetKit

@main
struct PsimeterWidgets: WidgetBundle {
    var body: some Widget {
        PsimeterWidget()
    }
}

struct PsimeterWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "Psimeter", intent: RegionIntent.self, provider: Provider()) { entry in
            EntryView(entry: entry)
        }
        .configurationDisplayName("psimeter")
        .description("NEA 24-hour PSI and WAQI AQI, read off a brass instrument.")
        .supportedFamilies([.systemSmall, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let barogram: Barogram
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        let region = Region.central
        let snapshot = SnapshotStore.standard.load(region)
            ?? Snapshot(region: region, psi: .unavailable(.offline), aqi: .unavailable(.offline), fetchedAt: .now)
        return Entry(date: .now, barogram: Barogram(observation: Observation(snapshot: snapshot, freshness: .held), trend: .unavailable(.unreadable)))
    }

    func snapshot(for configuration: RegionIntent, in context: Context) async -> Entry {
        Entry(date: .now, barogram: await AirFeed().barogram(configuration.region))
    }

    func timeline(for configuration: RegionIntent, in context: Context) async -> Timeline<Entry> {
        let now = Date.now
        let barogram = await AirFeed().barogram(configuration.region, now: now)
        var entries = [Entry(date: now, barogram: barogram)]
        if case .live(let report) = barogram.observation.snapshot.psi, Refresh.turnsStale(report) > now {
            entries.append(Entry(date: Refresh.turnsStale(report), barogram: barogram))
        }
        return Timeline(entries: entries, policy: .after(Refresh.nextReload(for: barogram, now: now)))
    }
}

struct EntryView: View {
    let entry: Entry

    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        let reading = Reading(entry.barogram.observation, now: entry.date)
        let finish = Finish(colorScheme: colorScheme, renderingMode: renderingMode)
        switch family {
        case .accessoryCircular:
            AccessoryCircular(reading: reading)
                .containerBackground(for: .widget) { Color.clear }
        case .accessoryRectangular:
            AccessoryRectangular(reading: reading)
                .containerBackground(for: .widget) { Color.clear }
        case .accessoryInline:
            AccessoryInline(reading: reading)
                .containerBackground(for: .widget) { Color.clear }
        case .systemLarge:
            BarographView(reading: reading, trend: entry.barogram.trend, finish: finish)
                .containerBackground(for: .widget) { LargePlate(finish: finish) }
        default:
            InstrumentView(reading: reading, finish: finish)
                .containerBackground(for: .widget) { Plate(finish: finish) }
        }
    }
}
