import Foundation

enum Demo {
    struct Case: Identifiable {
        let id: String
        let observation: Observation
        let now: Date
        var accented = false

        var reading: Reading { Reading(observation, now: now) }
    }

    static func sgt(_ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = SGT.timeZone
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: hour, minute: minute)) ?? .distantPast
    }

    static let observed = sgt(20, 30)
    static let regions: [Region: Int] = [.north: 126, .south: 159, .east: 173, .west: 197, .central: 183]
    static let psi = PSIReport(psi: regions, observedAt: observed)
    static let aqi = AQIReport(aqi: 168, station: "DEMO", observedAt: observed)

    static func snapshot(_ region: Region = .central, psi: Feed<PSIReport> = .live(psi), aqi: Feed<AQIReport> = .live(aqi)) -> Snapshot {
        Snapshot(region: region, psi: psi, aqi: aqi, fetchedAt: sgt(20, 45))
    }

    static let live = Case(id: "Live", observation: Observation(snapshot: snapshot(), freshness: .fetched), now: sgt(20, 45))

    static let cases: [Case] = [
        live,
        Case(id: "Stale", observation: Observation(snapshot: snapshot(), freshness: .held), now: sgt(23, 10)),
        Case(id: "No token", observation: Observation(snapshot: snapshot(aqi: .unavailable(.missingToken)), freshness: .fetched), now: sgt(20, 45)),
        Case(id: "Offline", observation: Observation(snapshot: snapshot(psi: .unavailable(.offline), aqi: .unavailable(.offline)), freshness: .fetched), now: sgt(20, 45)),
        Case(id: "Hazardous 342", observation: Observation(snapshot: snapshot(
            psi: .live(PSIReport(psi: [.north: 318, .south: 327, .east: 309, .west: 351, .central: 342], observedAt: observed)),
            aqi: .live(AQIReport(aqi: 301, station: "DEMO", observedAt: observed))), freshness: .fetched), now: sgt(20, 45)),
        Case(id: "Pegged 431", observation: Observation(snapshot: snapshot(
            psi: .live(PSIReport(psi: [.north: 402, .south: 415, .east: 398, .west: 446, .central: 431], observedAt: observed)),
            aqi: .live(AQIReport(aqi: 487, station: "DEMO", observedAt: observed))), freshness: .fetched), now: sgt(20, 45)),
        Case(id: "Accented", observation: live.observation, now: live.now, accented: true),
        Case(id: "Region West", observation: Observation(snapshot: snapshot(.west), freshness: .fetched), now: sgt(20, 45)),
    ]

    struct LargeCase: Identifiable {
        let id: String
        let barogram: Barogram
        let now: Date
        var accented = false

        var reading: Reading { Reading(barogram.observation, now: now) }
    }

    static let trend: Feed<PSITrend> = {
        let newest = sgt(20, 0)
        let hours = (0..<24).map { index -> PSIHour in
            let hour = newest.addingTimeInterval(TimeInterval(index - 23) * 3600)
            let rise = min(max((Double(index) - 9) / 9, 0), 1)
            let shape = (148 + 35 * rise * rise * (3 - 2 * rise)) / 183
            let psi = regions.mapValues { Int((Double($0) * shape).rounded()) }
            return PSIHour(hour: hour, observedAt: hour.addingTimeInterval(30 * 60), psi: psi)
        }
        return PSITrend(days: [PSIDay(day: SGTDay(containing: newest), hours: hours)]).map(Feed.live) ?? .unavailable(.unreadable)
    }()

    static let liveBarogram = Barogram(observation: live.observation, trend: trend)

    static let largeCases: [LargeCase] = [
        LargeCase(id: "live", barogram: liveBarogram, now: sgt(20, 45)),
        LargeCase(id: "stale", barogram: Barogram(observation: Observation(snapshot: snapshot(), freshness: .held), trend: trend), now: sgt(23, 10)),
        LargeCase(id: "trend", barogram: Barogram(observation: live.observation, trend: .unavailable(.offline)), now: sgt(20, 45)),
        LargeCase(id: "accented", barogram: liveBarogram, now: sgt(20, 45), accented: true),
    ]
}
