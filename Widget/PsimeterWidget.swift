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

enum Payload: Equatable, Sendable {
    case instrument(Observation)
    case barograph(Barogram)

    var observation: Observation {
        switch self {
        case .instrument(let observation): observation
        case .barograph(let barogram): barogram.observation
        }
    }

    var trend: Feed<PSITrend> {
        switch self {
        case .instrument: .unavailable(.unreadable)
        case .barograph(let barogram): barogram.trend
        }
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let payload: Payload
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        let region = Region.central
        let snapshot = SnapshotStore.standard.load(region)
            ?? Snapshot(region: region, psi: .unavailable(.offline), aqi: .unavailable(.offline), fetchedAt: .now)
        return Entry(date: .now, payload: .instrument(Observation(snapshot: snapshot, freshness: .held)))
    }

    func snapshot(for configuration: RegionIntent, in context: Context) async -> Entry {
        Entry(date: .now, payload: await payload(configuration.region, family: context.family, now: .now))
    }

    func timeline(for configuration: RegionIntent, in context: Context) async -> Timeline<Entry> {
        let now = Date.now
        let payload = await payload(configuration.region, family: context.family, now: now)
        var entries = [Entry(date: now, payload: payload)]
        if case .live(let report) = payload.observation.snapshot.psi {
            let turnsStale = report.observedAt.addingTimeInterval(PSIReport.staleAfter + 60)
            if turnsStale > now {
                entries.append(Entry(date: turnsStale, payload: payload))
            }
        }
        return Timeline(entries: entries, policy: .after(now.addingTimeInterval(15 * 60)))
    }

    private func payload(_ region: Region, family: WidgetFamily, now: Date) async -> Payload {
        switch family {
        case .systemLarge: .barograph(await AirFeed().barogram(region, now: now))
        default: .instrument(await AirFeed().observe(region, now: now))
        }
    }
}

struct EntryView: View {
    let entry: Entry

    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        let reading = Reading(entry.payload.observation, now: entry.date)
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
            BarographView(reading: reading, trend: entry.payload.trend, finish: finish)
                .containerBackground(for: .widget) { LargePlate(finish: finish) }
        default:
            InstrumentView(reading: reading, finish: finish)
                .containerBackground(for: .widget) { Plate(finish: finish) }
        }
    }
}
