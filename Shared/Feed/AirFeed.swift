import Foundation

struct AirFeed: Sendable {
    private let session: URLSession
    private let token: WAQIToken?
    private let store: SnapshotStore
    private let days: DayStore
    private let recent: RecentStore

    init(session: URLSession = .shared, token: WAQIToken? = .bundled, defaults: UserDefaults = .standard) {
        self.session = session
        self.token = token
        store = SnapshotStore(defaults: defaults)
        days = DayStore(defaults: defaults)
        recent = RecentStore(defaults: defaults)
    }

    func barogram(_ region: Region, now: Date = .now) async -> Barogram {
        let today = SGTDay(containing: now)
        let yesterday = today.previous
        let cachedYesterday = days.load(yesterday)
        async let todayFeed = psiDay(today, reusing: nil, now: now)
        async let yesterdayFeed = psiDay(yesterday, reusing: cachedYesterday, now: now)
        async let aqi = aqi(region, now: now)
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
    private func psiDay(_ day: SGTDay, reusing cached: PSIDay?, now: Date) async -> Feed<PSIDay> {
        if let cached, cached.isComplete { return .live(cached) }
        return await load(.psiDay(day), from: NEA.url(for: day), now: now) { data throws(FeedFailure) in
            try NEA.decodeDay(data, day: day)
        }
    }

    private func aqi(_ region: Region, now: Date) async -> Feed<AQIReport> {
        guard let token else { return .unavailable(.missingToken) }
        return await load(.station(region), from: WAQI.url(for: region, token: token), now: now, decode: WAQI.decode)
    }

    private func load<Report: Sendable>(
        _ source: Source,
        from url: URL,
        now: Date,
        decode: @escaping @Sendable (Data) throws(FeedFailure) -> Report
    ) async -> Feed<Report> {
        if let body = recent.load(source, now: now), let report = try? decode(body) {
            return .live(report)
        }
        let result = await Flights.shared.run(source) { [session, recent] in
            let fetched = await Self.request(url, session: session)
            if case .success(let body) = fetched {
                do throws(FeedFailure) {
                    _ = try decode(body)
                } catch {
                    return .failure(error)
                }
                recent.save(body, for: source, at: now)
            }
            return fetched
        }
        switch result {
        case .failure(let failure):
            return .unavailable(failure)
        case .success(let body):
            do throws(FeedFailure) {
                return .live(try decode(body))
            } catch {
                return .unavailable(error)
            }
        }
    }

    private static func request(_ url: URL, session: URLSession) async -> Result<Data, FeedFailure> {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: URLRequest(url: url, timeoutInterval: 15))
        } catch {
            return .failure(.offline)
        }
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return .failure(.unreadable)
        }
        return .success(data)
    }
}
