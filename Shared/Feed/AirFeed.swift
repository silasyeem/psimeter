import Foundation

struct AirFeed: Sendable {
    private let session: URLSession
    private let token: WAQIToken?
    private let store: SnapshotStore
    private let days: DayStore

    init(session: URLSession = .shared, token: WAQIToken? = .bundled, store: SnapshotStore = .standard, days: DayStore = .standard) {
        self.session = session
        self.token = token
        self.store = store
        self.days = days
    }

    func fetch(_ region: Region, now: Date = .now) async -> Snapshot {
        async let psi = load(NEA.endpoint, decode: NEA.decode)
        async let aqi = aqi(region)
        return await Snapshot(region: region, psi: psi, aqi: aqi, fetchedAt: now)
    }

    func observe(_ region: Region, now: Date = .now) async -> Observation {
        await settle(fetch(region, now: now))
    }

    func barogram(_ region: Region, now: Date = .now) async -> Barogram {
        let today = SGTDay(containing: now)
        let yesterday = today.previous
        let cachedYesterday = days.load(yesterday)
        async let todayFeed = psiDay(today, reusing: nil)
        async let yesterdayFeed = psiDay(yesterday, reusing: cachedYesterday)
        async let aqi = aqi(region)
        let (liveToday, liveYesterday) = await (todayFeed, yesterdayFeed)

        for day in [liveToday, liveYesterday].compactMap(\.report) {
            days.save(day, keeping: [today, yesterday])
        }
        let failure: FeedFailure = switch (liveToday, liveYesterday) {
        case (.unavailable(let failure), _), (_, .unavailable(let failure)): failure
        default: .unreadable
        }

        // Yesterday stands in only for an empty today, never a failed one, because its last hour would overwrite a newer held snapshot.
        let newest = liveToday.report.flatMap { $0.hours.last ?? liveYesterday.report?.hours.last }
        let psi: Feed<PSIReport> = newest.map { .live(PSIReport(psi: $0.psi, observedAt: $0.observedAt)) } ?? .unavailable(failure)
        let observation = await settle(Snapshot(region: region, psi: psi, aqi: aqi, fetchedAt: now))

        let trendDays = [liveToday.report ?? days.load(today), liveYesterday.report ?? cachedYesterday].compactMap { $0 }
        let trend: Feed<PSITrend> = PSITrend(days: trendDays).map { .live($0) } ?? .unavailable(failure)
        return Barogram(observation: observation, trend: trend)
    }

    private func settle(_ fresh: Snapshot) -> Observation {
        switch fresh.psi {
        case .live:
            store.save(fresh)
        case .unavailable:
            if let held = store.load(fresh.region) {
                return Observation(snapshot: held, freshness: .held)
            }
        }
        return Observation(snapshot: fresh, freshness: .fetched)
    }

    // A complete day never changes, so a cached one stands in for its request.
    private func psiDay(_ day: SGTDay, reusing cached: PSIDay?) async -> Feed<PSIDay> {
        if let cached, cached.isComplete { return .live(cached) }
        return await load(NEA.url(for: day)) { data throws(FeedFailure) in try NEA.decodeDay(data, day: day) }
    }

    private func aqi(_ region: Region) async -> Feed<AQIReport> {
        guard let token else { return .unavailable(.missingToken) }
        return await load(WAQI.url(for: region, token: token), decode: WAQI.decode)
    }

    private func load<Report: Sendable>(
        _ url: URL,
        decode: (Data) throws(FeedFailure) -> Report
    ) async -> Feed<Report> {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: URLRequest(url: url, timeoutInterval: 15))
        } catch {
            return .unavailable(.offline)
        }
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return .unavailable(.unreadable)
        }
        do {
            return .live(try decode(data))
        } catch {
            return .unavailable(error)
        }
    }
}
