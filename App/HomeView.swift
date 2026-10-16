import SwiftUI
import WidgetKit

struct HomeView: View {
    @State private var region: Region = .central
    @State private var observation: Observation?
    @Environment(\.colorScheme) private var colorScheme

    private let token = WAQIToken.bundled

    var body: some View {
        NavigationStack {
            List {
                Section {
                    instrument
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    Picker("Region", selection: $region) {
                        ForEach(Region.allCases, id: \.self) { Text($0.name).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section("AQI feed") {
                    if let feed = observation?.snapshot.aqi {
                        LabeledContent("Status", value: aqiStatus(feed))
                    }
                    #if DEBUG
                    LabeledContent("Token", value: token == nil ? "Not set" : "Set")
                    if token == nil {
                        Text("Add WAQI_TOKEN to .env, run scripts/sync-secrets.sh, then rebuild. Until then the AQI counter stays blank.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    #endif
                }

                Section("Sources") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("24-hour PSI").font(.headline)
                        Text("National Environment Agency, via data.gov.sg. Contains information from the PSI dataset made available under the terms of the Singapore Open Data Licence version 1.0.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Link("Singapore Open Data Licence", destination: URL(string: "https://data.gov.sg/open-data-licence")!)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AQI").font(.headline)
                        Text(waqiCredit)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Link("World Air Quality Index Project (aqicn.org)", destination: URL(string: "https://aqicn.org/")!)
                    Text("Archivo Black by Omnibus-Type, SIL Open Font License 1.1")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("psimeter")
            .refreshable { await load() }
            .task(id: region) { await load() }
        }
    }

    private var instrument: some View {
        Group {
            if let observation {
                InstrumentTile(reading: Reading(observation, now: .now), finish: colorScheme == .dark ? .night : .day)
            } else {
                InstrumentTile(reading: Reading(Observation(
                    snapshot: Snapshot(region: region, psi: .unavailable(.offline), aqi: .unavailable(.offline), fetchedAt: .now),
                    freshness: .fetched), now: .now), finish: colorScheme == .dark ? .night : .day)
                    .opacity(0.5)
                    .overlay { ProgressView() }
            }
        }
        .frame(maxWidth: 360)
        .frame(maxWidth: .infinity)
    }

    private var waqiCredit: String {
        let station: String? = if case .live(let report) = observation?.snapshot.aqi { report.station } else { nil }
        let base = "World Air Quality Index Project and the originating environmental protection agency."
        return station.map { "\(base) Station: \($0)." } ?? base
    }

    private func aqiStatus(_ feed: Feed<AQIReport>) -> String {
        switch feed {
        case .live(let report): "Live, AQI \(report.aqi)"
        case .unavailable(.missingToken): "Unavailable"
        case .unavailable(.offline): "Offline"
        case .unavailable(.unreadable): "Unreadable reply"
        }
    }

    private func load() async {
        if observation?.snapshot.region != region {
            observation = SnapshotStore.standard.load(region).map { Observation(snapshot: $0, freshness: .held) }
        }
        let fetched = await AirFeed().barogram(region).observation
        observation = fetched
        if fetched.freshness == .fetched, fetched.snapshot.psi.report != nil {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
