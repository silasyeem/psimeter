import Foundation
import Synchronization

var failures = 0

@MainActor func check(_ passed: Bool, _ claim: String) {
    print(passed ? "PASS" : "FAIL", claim)
    if !passed { failures += 1 }
}

@MainActor func get(_ url: URL, _ name: String) async -> Data? {
    do {
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url, timeoutInterval: 15))
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        check(status == 200, "\(name) answered HTTP \(status)")
        return status == 200 ? data : nil
    } catch {
        check(false, "\(name) unreachable: \(error.localizedDescription)")
        return nil
    }
}

var lastNEA: ContinuousClock.Instant?

// data.gov.sg answers HTTP 429 after a handful of rapid unkeyed calls.
@MainActor func paceNEA() async {
    if let lastNEA { try? await Task.sleep(until: lastNEA + .seconds(3)) }
    lastNEA = .now
}

let suite = "psimeter.feed-check"

// One fixed suite, cleared before each scenario, so a crashed run cannot leave a cache behind and reruns cannot pile up plists.
@MainActor func scratch() -> UserDefaults {
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

// An oracle independent of the feed's own timestamp parser.
func referenceDate(_ text: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: text) { return date }
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter.date(from: text)
}

func failure<T>(_ decode: (Data) throws(FeedFailure) -> T, _ data: Data) -> FeedFailure? {
    do {
        _ = try decode(data)
        return nil
    } catch {
        return error
    }
}

func ascending(_ hours: [PSIHour]) -> Bool {
    zip(hours, hours.dropFirst()).allSatisfy { $0.hour < $1.hour }
}

final class Stub: URLProtocol {
    enum Reply: Sendable {
        case fail(URLError.Code)
        case serve(status: Int, body: Data)
    }

    static let route = Mutex<@Sendable (URL) -> Reply>({ _ in .fail(.notConnectedToInternet) })
    static let requests = Mutex<[URL]>([])
    static let latency = Mutex<TimeInterval>(0)

    static var hosts: [String] {
        requests.withLock { $0.map { $0.host() ?? "?" } }
    }

    static func session(_ reply: Reply) -> URLSession {
        session { _ in reply }
    }

    static func session(days: [SGTDay: Reply]) -> URLSession {
        session { url in days.first { NEA.url(for: $0.key).absoluteString == url.absoluteString }?.value ?? .fail(.unsupportedURL) }
    }

    static func session(_ route: @escaping @Sendable (URL) -> Reply) -> URLSession {
        Stub.route.withLock { $0 = route }
        Stub.requests.withLock { $0 = [] }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [Stub.self]
        return URLSession(configuration: configuration)
    }

    static func takeAll() -> [String] {
        requests.withLock { requests in
            defer { requests = [] }
            return requests.map { url in
                url.host() == "api.waqi.info"
                    ? "waqi \(url.path().split(separator: "/").last ?? "?")"
                    : "nea \(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "date" }?.value ?? "<realtime>")"
            }.sorted()
        }
    }

    static func takeDays() -> [String] {
        requests.withLock { requests in
            defer { requests = [] }
            return requests.map { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "date" }?.value ?? "<none>" }.sorted()
        }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        Stub.requests.withLock { $0.append(url) }
        let delay = Stub.latency.withLock { $0 }
        if delay > 0 { Thread.sleep(forTimeInterval: delay) }
        switch Stub.route.withLock({ $0 })(url) {
        case .fail(let code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        case .serve(let status, let body):
            guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

struct RawNEA: Decodable {
    let data: Payload
    struct Payload: Decodable { let items: [Item] }
    struct Item: Decodable { let timestamp, updatedTimestamp: String }
}

struct RawWAQI: Decodable {
    let data: Station
    struct Station: Decodable { let time: Time }
    struct Time: Decodable { let iso: String }
}

let sgt = TimeZone(identifier: "Asia/Singapore")!
let sgtFormat = Date.ISO8601FormatStyle(timeZoneSeparator: .colon, timeZone: sgt)
let rateLimited = Data(#"{"code":24,"name":"TOO_MANY_REQUESTS","data":null,"errorMsg":"Rate limit exceeded. Please try again in 10 seconds."}"#.utf8)

func synthHours(_ day: SGTDay, _ range: Range<Int>) -> [PSIHour] {
    range.map { index in
        let hour = day.start.addingTimeInterval(Double(index) * 3600)
        let psi = Dictionary(uniqueKeysWithValues: Region.allCases.enumerated().map { ($1, 40 + index + $0) })
        return PSIHour(hour: hour, observedAt: hour.addingTimeInterval(30 * 60), psi: psi)
    }
}

@MainActor func itemJSON(_ hour: PSIHour, dropping missing: Region? = nil) -> String {
    let regions = hour.psi.filter { $0.key != missing }.map { #""\#($0.key.rawValue)":\#($0.value)"# }.joined(separator: ",")
    return #"{"timestamp":"\#(hour.hour.formatted(sgtFormat))","updatedTimestamp":"\#(hour.observedAt.formatted(sgtFormat))","readings":{"psi_twenty_four_hourly":{\#(regions)}}}"#
}

func dayJSON(_ items: [String]) -> Data {
    Data(#"{"code":0,"data":{"items":[\#(items.joined(separator: ","))]},"errorMsg":""}"#.utf8)
}

@MainActor func payload(_ day: PSIDay) -> Data {
    dayJSON(day.hours.reversed().map { itemJSON($0) })
}

check(WAQIToken(nil) == nil && WAQIToken("") == nil && WAQIToken(" \n\t ") == nil, "WAQIToken rejects nil, empty and whitespace-only")
check(WAQIToken("  abc123 \n")?.value == "abc123", "WAQIToken trims surrounding whitespace")

var livePSI: PSIReport?
var liveNEA: Data?
var realtimeHour: Date?
await paceNEA()
if let neaData = await get(NEA.endpoint, "NEA realtime endpoint") {
    liveNEA = neaData
    let rawItem = (try? JSONDecoder().decode(RawNEA.self, from: neaData))?.data.items.first
    realtimeHour = rawItem.flatMap { referenceDate($0.timestamp) }
    let raw = rawItem?.updatedTimestamp ?? "<missing>"
    let realtimeDay = realtimeHour.map(SGTDay.init(containing:)) ?? SGTDay(containing: .now)
    let decodeRealtime = { (data: Data) throws(FeedFailure) -> PSIDay in try NEA.decodeDay(data, day: realtimeDay) }
    switch Result(catching: { try decodeRealtime(neaData) }) {
    case .success(let day):
        if day.hours.count == 1, let hour = day.hours.last {
            let report = PSIReport(psi: hour.psi, observedAt: hour.observedAt)
            livePSI = report
            let values = Region.allCases.map { "\($0.name) \(report.psi[$0].map(String.init) ?? "-")" }.joined(separator: ", ")
            let regionsComplete = Set(report.psi.keys) == Set(Region.allCases)
            let offsetHonoured = raw.hasSuffix("+08:00") && referenceDate(raw) == report.observedAt
            check(regionsComplete && offsetHonoured, "NEA realtime payload decodes as one hour of its day: \(values); updated \(report.observedAt.formatted(sgtFormat)) SGT (raw \(raw))")
        } else {
            check(false, "NEA realtime payload decodes to \(day.hours.count) hours, expected 1")
        }
    case .failure(let error):
        check(false, "NEA realtime decode failed with \(error)")
    }

    let text = String(decoding: neaData, as: UTF8.self)
    let withoutCentral = text.replacingOccurrences(of: #""central"\s*:"#, with: #""centre":"#, options: .regularExpression)
    let nullCentral = text.replacingOccurrences(of: #""central"\s*:\s*\d+"#, with: #""central":null"#, options: .regularExpression)
    check(withoutCentral != text && nullCentral != text, "NEA mutations changed the live payload")
    let broken: [(String, Data)] = [
        ("central region missing", Data(withoutCentral.utf8)),
        ("central region null", Data(nullCentral.utf8)),
        ("payload truncated", neaData.prefix(neaData.count / 2)),
        ("rate-limit reply", rateLimited),
    ]
    for (name, data) in broken {
        check(failure(decodeRealtime, data) == .unreadable, "NEA \(name) is .unreadable")
    }
}

let today = SGTDay(containing: .now)
let yesterday = today.previous
check(NEA.url(for: today).absoluteString == "https://api-open.data.gov.sg/v2/real-time/api/psi?date=\(today.iso)", "NEA day URL is \(NEA.url(for: today).absoluteString)")

@MainActor func liveDay(_ day: SGTDay, _ name: String) async -> PSIDay? {
    await paceNEA()
    guard let data = await get(NEA.url(for: day), "NEA \(name) (\(day.iso))") else { return nil }
    let raw = (try? JSONDecoder().decode(RawNEA.self, from: data))?.data.items.compactMap { referenceDate($0.timestamp) } ?? []
    switch Result(catching: { try NEA.decodeDay(data, day: day) }) {
    case .success(let decoded):
        let hours = decoded.hours.map(\.hour)
        let everyItemKept = hours.count == raw.count && Set(hours) == Set(raw)
        let regionsComplete = decoded.hours.allSatisfy { Set($0.psi.keys) == Set(Region.allCases) }
        let span = hours.isEmpty ? "none yet" : "\(hours[0].formatted(sgtFormat)) to \(hours[hours.count - 1].formatted(sgtFormat))"
        check(everyItemKept && ascending(decoded.hours) && regionsComplete, "NEA \(name) decodes \(hours.count) ascending hours, one per raw item, all five regions each (\(span))")
        return decoded
    case .failure(let error):
        check(false, "NEA \(name) decode failed with \(error)")
        return nil
    }
}

let liveToday = await liveDay(today, "today")
let liveYesterday = await liveDay(yesterday, "yesterday")
if let liveYesterday {
    let lastHour = yesterday.start.addingTimeInterval(23 * 3600)
    check(liveYesterday.isComplete && liveYesterday.hours.first?.hour == yesterday.start && liveYesterday.hours.last?.hour == lastHour, "NEA yesterday is complete: 24 hours, 00:00 to 23:00 SGT")
}
let dayFeedNewest = liveToday?.hours.last ?? liveYesterday?.hours.last
if let newest = dayFeedNewest, let livePSI, let realtimeHour {
    let values = Region.allCases.map { "\($0.name) \(newest.psi[$0].map(String.init) ?? "-")" }.joined(separator: ", ")
    check(newest.hour == realtimeHour && newest.observedAt == livePSI.observedAt && newest.psi == livePSI.psi, "day feed's newest hour equals the realtime item: \(newest.hour.formatted(sgtFormat)), updated \(newest.observedAt.formatted(sgtFormat)), \(values)")
} else {
    check(false, "the day feed and the realtime endpoint both have a newest hour to compare")
}

let stubToday = SGTDay(year: 2026, month: 3, day: 1)
let stubYesterday = stubToday.previous
let stubNow = stubToday.start.addingTimeInterval(9.5 * 3600)
let fullYesterday = PSIDay(day: stubYesterday, hours: synthHours(stubYesterday, 0..<24))
let morning = PSIDay(day: stubToday, hours: synthHours(stubToday, 0..<10))

let four = synthHours(stubToday, 0..<4)
let revised = PSIHour(hour: four[2].hour, observedAt: four[2].observedAt.addingTimeInterval(600), psi: four[2].psi.mapValues { $0 + 100 })
let superseded = PSIHour(hour: four[0].hour, observedAt: four[0].observedAt.addingTimeInterval(-600), psi: four[0].psi.mapValues { $0 + 200 })
let shuffled = dayJSON([four[2], four[0], four[3], revised, four[1], superseded].map { itemJSON($0) })
let decodeStubDay = { (data: Data) throws(FeedFailure) -> PSIDay in try NEA.decodeDay(data, day: stubToday) }
check((try? NEA.decodeDay(shuffled, day: stubToday)) == PSIDay(day: stubToday, hours: [four[0], four[1], revised, four[3]]), "NEA day with shuffled and duplicated items decodes ascending, one per hour, latest update winning")
let missingRegion = dayJSON([itemJSON(four[1]), itemJSON(four[0], dropping: .east)])
check(failure(decodeStubDay, missingRegion) == .unreadable, "NEA day with an item missing a region is .unreadable")
check((try? NEA.decodeDay(dayJSON([]), day: stubToday)) == PSIDay(day: stubToday, hours: []), "NEA day with an empty items array is a valid empty day")
let wrongDay = dayJSON([itemJSON(four[0]), itemJSON(fullYesterday.hours[23])])
check(failure(decodeStubDay, wrongDay) == .unreadable, "NEA day with an hour from another day is .unreadable")
check(failure(decodeStubDay, rateLimited) == .unreadable, "NEA day rate-limit reply is .unreadable")

if let liveToday, let liveYesterday {
    if let trend = PSITrend(days: [liveYesterday, liveToday]) {
        let newest = trend.newest.hour
        let inWindow = trend.hours.allSatisfy { $0.hour > newest.addingTimeInterval(-PSITrend.span) && $0.hour <= newest }
        check(trend.hours.count <= 24 && inWindow && ascending(trend.hours), "PSITrend over live yesterday+today: \(trend.hours.count) ascending hours, \(trend.hours[0].hour.formatted(sgtFormat)) to \(newest.formatted(sgtFormat)), all within (newest - 24 h, newest]")
    } else {
        check(false, "PSITrend over live yesterday+today is nil")
    }
}
check(PSITrend(days: [morning, fullYesterday])?.hours == Array(fullYesterday.hours[10...] + morning.hours), "PSITrend over a full yesterday and today to 09:00 keeps exactly yesterday 10:00 to today 09:00")
let oneHour = PSIDay(day: stubToday, hours: Array(morning.hours.prefix(1)))
let twoHours = PSIDay(day: stubToday, hours: Array(morning.hours.prefix(2)))
check(PSITrend(days: []) == nil && PSITrend(days: [PSIDay(day: stubToday, hours: [])]) == nil && PSITrend(days: [oneHour]) == nil && PSITrend(days: [twoHours]) != nil, "PSITrend with fewer than 2 hours is nil; 2 hours make a trend")

let stationURL = WAQI.url(for: .central, token: WAQIToken("demo")!)
check(stationURL.absoluteString == "https://api.waqi.info/feed/@1666/?token=demo", "WAQI URL is \(stationURL.absoluteString)")
check(WAQI.url(for: .west, token: WAQIToken("demo")!).path() == "/feed/@1665/", "WAQI URL follows the region's station")

var liveAQI: AQIReport?
if let waqiData = await get(URL(string: "https://api.waqi.info/feed/shanghai/?token=demo")!, "WAQI demo feed (Shanghai)") {
    let raw = (try? JSONDecoder().decode(RawWAQI.self, from: waqiData))?.data.time.iso ?? "<missing>"
    switch Result(catching: { try WAQI.decode(waqiData) }) {
    case .success(let report):
        liveAQI = report
        let sane = (0...999).contains(report.aqi) && !report.station.isEmpty && referenceDate(raw) == report.observedAt
        check(sane, "WAQI demo payload decodes: AQI \(report.aqi) at \(report.station), observed \(raw)")
    case .failure(let error):
        check(false, "WAQI demo decode failed with \(error)")
    }
}

// The demo token answers every query with Shanghai, so only a real token proves the Singapore stations resolve.
if let token = ProcessInfo.processInfo.environment["WAQI_TOKEN"].flatMap(WAQIToken.init) {
    for region in Region.allCases {
        guard let data = await get(WAQI.url(for: region, token: token), "WAQI \(region.name) station") else { continue }
        let raw = (try? JSONDecoder().decode(RawWAQI.self, from: data))?.data.time.iso ?? "<missing>"
        switch Result(catching: { try WAQI.decode(data) }) {
        case .success(let report):
            let sane = (0...999).contains(report.aqi) && report.station == "\(region.name), Singapore" && referenceDate(raw) == report.observedAt
            check(sane, "WAQI \(region.name): AQI \(report.aqi) at \(report.station), observed \(raw)")
        case .failure(let error):
            check(false, "WAQI \(region.name) station decode failed with \(error)")
        }
    }
} else {
    print("SKIP WAQI Singapore station checks: WAQI_TOKEN is not set")
}
if let invalidReply = await get(WAQI.url(for: .central, token: WAQIToken("feed-check-not-a-token")!), "WAQI with an invalid token") {
    check(failure(WAQI.decode, invalidReply) == .unreadable, "WAQI live invalid-key reply is .unreadable")
}

let dash = Data(#"{"status":"ok","data":{"aqi":"-","city":{"name":"Singapore"},"time":{"iso":"2026-10-14T23:00:00+08:00"}}}"#.utf8)
check(failure(WAQI.decode, dash) == .unreadable, #"WAQI "aqi":"-" is .unreadable"#)
let invalidKey = Data(#"{"status":"error","data":"Invalid key"}"#.utf8)
check(failure(WAQI.decode, invalidKey) == .unreadable, "WAQI error status is .unreadable")

let offline = Stub.session(.fail(.notConnectedToInternet))
let offlineSuite = scratch()
let cold = await AirFeed(session: offline, token: nil, defaults: offlineSuite).barogram(.central).observation
check(cold.freshness == .fetched && cold.snapshot.psi == .unavailable(.offline), "offline barogram with an empty cache is PSI .offline, .fetched")
check(cold.snapshot.aqi == .unavailable(.missingToken), "offline barogram without a token is AQI .missingToken")
check(Set(Stub.hosts) == ["api-open.data.gov.sg"], "no WAQI request is made without a token (hosts: \(Set(Stub.hosts).sorted()))")
check(SnapshotStore(defaults: offlineSuite).load(.central) == nil, "an observation without live PSI is not cached")

let tokenOffline = await AirFeed(session: offline, token: WAQIToken("feed-check-not-a-token"), defaults: scratch()).barogram(.central).observation
check(tokenOffline.snapshot.aqi == .unavailable(.offline), "offline barogram with a token is AQI .offline")

if let liveNEA, let livePSI {
    let refusedSuite = scratch()
    let refused = await AirFeed(session: Stub.session(.serve(status: 503, body: liveNEA)), token: nil, defaults: refusedSuite).barogram(.central, now: livePSI.observedAt).observation
    check(refused.freshness == .fetched && refused.snapshot.psi == .unavailable(.unreadable) && SnapshotStore(defaults: refusedSuite).load(.central) == nil, "HTTP 503 is PSI .unreadable even with a valid body, and is not cached")
    let warmSuite = scratch()
    let warm = await AirFeed(session: Stub.session(.serve(status: 200, body: liveNEA)), token: nil, defaults: warmSuite).barogram(.central, now: livePSI.observedAt).observation
    check(warm.freshness == .fetched && warm.snapshot.psi == .live(livePSI), "barogram with live PSI is .fetched")
    check(SnapshotStore(defaults: warmSuite).load(.central) == warm.snapshot, "barogram with live PSI caches its snapshot")
}

if let livePSI, let liveAQI {
    let heldSuite = scratch()
    let store = SnapshotStore(defaults: heldSuite)
    let full = Snapshot(region: .central, psi: .live(livePSI), aqi: .live(liveAQI), fetchedAt: .now)
    store.save(full)
    let held = await AirFeed(session: Stub.session(.fail(.timedOut)), token: nil, defaults: heldSuite).barogram(.central).observation
    check(held.freshness == .held && held.snapshot == full, "offline barogram after a live snapshot returns it whole (AQI included), .held")
    let otherRegion = await AirFeed(session: Stub.session(.fail(.timedOut)), token: nil, defaults: heldSuite).barogram(.north).observation
    check(otherRegion.freshness == .fetched && otherRegion.snapshot.psi == .unavailable(.offline), "the cache is per region")

    let decoded = try? JSONDecoder().decode(Snapshot.self, from: JSONEncoder().encode(full))
    check(decoded == full, "live snapshot round-trips through JSON equal")
    check(store.load(.central) == full, "live snapshot round-trips through the store equal")
    let offlineDecoded = try? JSONDecoder().decode(Snapshot.self, from: JSONEncoder().encode(cold.snapshot))
    check(offlineDecoded == cold.snapshot, "unavailable-feed snapshot round-trips through JSON equal")
} else {
    check(false, "live PSI and AQI reports exist for the cache checks")
}

let daySuite = scratch()
let dayStore = DayStore(defaults: daySuite)
let older = PSIDay(day: stubYesterday.previous, hours: synthHours(stubYesterday.previous, 0..<24))
dayStore.save(older, keeping: [older.day, stubYesterday])
dayStore.save(fullYesterday, keeping: [older.day, stubYesterday])
check(dayStore.load(older.day) == older && dayStore.load(stubYesterday) == fullYesterday, "DayStore round-trips saved days equal")
dayStore.save(morning, keeping: [stubToday, stubYesterday])
check(dayStore.load(older.day) == nil && dayStore.load(stubYesterday) == fullYesterday && dayStore.load(stubToday) == morning, "DayStore save prunes every day outside recent (\(older.day.iso) dropped)")
dayStore.save(morning, keeping: [stubToday, stubYesterday])
let dayKeys = daySuite.dictionaryRepresentation().keys.filter { $0.hasPrefix("psi.") }
check(dayStore.load(stubYesterday) == fullYesterday && dayStore.load(stubToday) == morning && dayKeys.count == 1, "DayStore save is idempotent and keeps one key (\(dayKeys.sorted()))")
dayStore.save(older, keeping: [stubToday, stubYesterday])
check(dayStore.load(older.day) == nil, "DayStore does not keep a saved day outside recent")

func stubFeed(_ suite: UserDefaults, _ replies: [SGTDay: Stub.Reply]) -> AirFeed {
    AirFeed(session: Stub.session(days: replies), token: nil, defaults: suite)
}

func report(_ hour: PSIHour) -> PSIReport {
    PSIReport(psi: hour.psi, observedAt: hour.observedAt)
}

func expectedTrend(_ days: PSIDay...) -> Feed<PSITrend> {
    PSITrend(days: days).map { .live($0) } ?? .unavailable(.unreadable)
}

let serveYesterday = Stub.Reply.serve(status: 200, body: payload(fullYesterday))
let serveMorning = Stub.Reply.serve(status: 200, body: payload(morning))

let cacheSuite = scratch()
let cachedFeed = stubFeed(cacheSuite, [stubToday: serveMorning, stubYesterday: serveYesterday])
let first = await cachedFeed.barogram(.central, now: stubNow)
let firstDays = Stub.takeDays()
check(firstDays == [stubYesterday.iso, stubToday.iso] && first.observation.freshness == .fetched && first.observation.snapshot.psi == .live(report(morning.hours[9])) && first.trend == expectedTrend(morning, fullYesterday), "first barogram makes 2 NEA requests \(firstDays): PSI is today's 09:00, .fetched, trend .live with \(first.trend.report?.hours.count ?? 0) hours")
check(SnapshotStore(defaults: cacheSuite).load(.central) == first.observation.snapshot, "barogram saves its live snapshot to the shared SnapshotStore")
let second = await cachedFeed.barogram(.central, now: stubNow.addingTimeInterval(5 * 60))
let secondDays = Stub.takeDays()
check(secondDays == [stubToday.iso] && second.observation.snapshot.psi == first.observation.snapshot.psi && second.trend == first.trend, "a barogram after the reuse window makes 1 NEA request \(secondDays): yesterday stays cached")

let partialSuite = scratch()
DayStore(defaults: partialSuite).save(PSIDay(day: stubYesterday, hours: Array(fullYesterday.hours.prefix(23))), keeping: [stubToday, stubYesterday])
_ = await stubFeed(partialSuite, [stubToday: serveMorning, stubYesterday: serveYesterday]).barogram(.central, now: stubNow)
let partialDays = Stub.takeDays()
check(partialDays == [stubYesterday.iso, stubToday.iso] && DayStore(defaults: partialSuite).load(stubYesterday) == fullYesterday, "an incomplete cached yesterday (23 hours) is refetched: 2 NEA requests \(partialDays), the complete day replaces it")

let heldSuite = scratch()
let earlier = PSIDay(day: stubToday, hours: Array(morning.hours.prefix(8)))
DayStore(defaults: heldSuite).save(fullYesterday, keeping: [stubToday, stubYesterday])
DayStore(defaults: heldSuite).save(earlier, keeping: [stubToday, stubYesterday])
let heldSnapshot = Snapshot(region: .central, psi: .live(report(earlier.hours[7])), aqi: .unavailable(.missingToken), fetchedAt: stubNow.addingTimeInterval(-3600))
SnapshotStore(defaults: heldSuite).save(heldSnapshot)
let held = await stubFeed(heldSuite, [stubToday: .fail(.notConnectedToInternet), stubYesterday: serveYesterday]).barogram(.central, now: stubNow)
let heldDays = Stub.takeDays()
check(held.observation == Observation(snapshot: heldSnapshot, freshness: .held) && held.trend == expectedTrend(earlier, fullYesterday) && heldDays == [stubToday.iso], "today offline with cached days and snapshot: observation .held, trend .live from the cache (\(held.trend.report?.hours.count ?? 0) hours), 1 NEA request \(heldDays)")

let staleSuite = scratch()
SnapshotStore(defaults: staleSuite).save(heldSnapshot)
let stale = await stubFeed(staleSuite, [stubToday: .fail(.timedOut), stubYesterday: serveYesterday]).barogram(.central, now: stubNow)
_ = Stub.takeDays()
check(stale.observation == Observation(snapshot: heldSnapshot, freshness: .held) && SnapshotStore(defaults: staleSuite).load(.central) == heldSnapshot && stale.trend == expectedTrend(fullYesterday), "today offline but yesterday live: yesterday's 23:00 does not replace the held snapshot, trend is yesterday's 24 hours")

let coldSuite = scratch()
let coldBarogram = await stubFeed(coldSuite, [stubToday: .fail(.notConnectedToInternet), stubYesterday: .fail(.notConnectedToInternet)]).barogram(.central, now: stubNow)
let coldDays = Stub.takeDays()
let nothingCached = SnapshotStore(defaults: coldSuite).load(.central) == nil && DayStore(defaults: coldSuite).load(stubToday) == nil && DayStore(defaults: coldSuite).load(stubYesterday) == nil
check(coldBarogram.observation.freshness == .fetched && coldBarogram.observation.snapshot.psi == .unavailable(.offline) && coldBarogram.trend == .unavailable(.offline) && nothingCached, "offline with nothing cached: PSI .unavailable(.offline) .fetched, trend .unavailable(.offline), nothing cached, requests \(coldDays)")

let midnightSuite = scratch()
let emptyDay = Stub.Reply.serve(status: 200, body: dayJSON([]))
let justAfterMidnight = stubToday.start.addingTimeInterval(5 * 60)
let midnight = await stubFeed(midnightSuite, [stubToday: emptyDay, stubYesterday: serveYesterday]).barogram(.central, now: justAfterMidnight)
let midnightDays = Stub.takeDays()
check(midnight.observation.freshness == .fetched && midnight.observation.snapshot.psi == .live(report(fullYesterday.hours[23])) && midnight.trend == expectedTrend(fullYesterday), "today live with 0 items and yesterday live: PSI is yesterday's 23:00, .fetched, trend is yesterday's 24 hours, requests \(midnightDays)")
check(DayStore(defaults: midnightSuite).load(stubToday) == PSIDay(day: stubToday, hours: []), "an empty today is cached as a valid empty day")

let darkSuite = scratch()
let dark = await stubFeed(darkSuite, [stubToday: emptyDay, stubYesterday: .fail(.timedOut)]).barogram(.central, now: justAfterMidnight)
_ = Stub.takeDays()
check(dark.observation.snapshot.psi == .unavailable(.offline) && dark.trend == .unavailable(.offline), "today live with 0 items and yesterday offline: PSI and trend .unavailable(.offline)")

func waqiJSON(_ region: Region) -> Data {
    Data(#"{"status":"ok","data":{"aqi":\#(100 + region.waqiStation % 10),"city":{"name":"\#(region.name), Singapore"},"time":{"iso":"2026-03-01T09:00:00+08:00"}}}"#.utf8)
}

@MainActor func crowdSession(_ days: [SGTDay: Stub.Reply], latency: TimeInterval) -> URLSession {
    Stub.latency.withLock { $0 = latency }
    let stations = Dictionary(uniqueKeysWithValues: Region.allCases.map { ("/feed/@\($0.waqiStation)/", waqiJSON($0)) })
    return Stub.session { url in
        if url.host() == "api.waqi.info" {
            return stations[url.path()].map { .serve(status: 200, body: $0) } ?? .fail(.unsupportedURL)
        }
        return days.first { NEA.url(for: $0.key).absoluteString == url.absoluteString }?.value ?? .fail(.unsupportedURL)
    }
}

let stationToken = WAQIToken("feed-check-not-a-token")
let liveMorning = Feed<PSIReport>.live(report(morning.hours[9]))

let crowdSuite = scratch()
DayStore(defaults: crowdSuite).save(fullYesterday, keeping: [stubToday, stubYesterday])
let crowdFeedSession = crowdSession([stubToday: serveMorning], latency: 0.4)
let families: [(name: String, region: Region)] = [("small", .central), ("large", .central), ("circular", .central), ("rectangular", .north), ("inline", .north)]
let crowdFeeds = families.map { _ in AirFeed(session: crowdFeedSession, token: stationToken, defaults: crowdSuite) }
let crowdNow = stubNow
let crowd = await withTaskGroup(of: Barogram.self) { group in
    for (feed, family) in zip(crowdFeeds, families) {
        let region = family.region
        group.addTask { await feed.barogram(region, now: crowdNow) }
    }
    var results: [Barogram] = []
    for await barogram in group { results.append(barogram) }
    return results
}
Stub.latency.withLock { $0 = 0 }
let crowdRequests = Stub.takeAll()
let crowdLive = crowd.count == 5 && crowd.allSatisfy { $0.observation.freshness == .fetched && $0.observation.snapshot.psi == liveMorning && $0.observation.snapshot.aqi.report != nil && $0.trend.report != nil }
check(crowdRequests == ["nea \(stubToday.iso)", "waqi @1662", "waqi @1666"] && crowdLive, "five concurrent barograms (\(families.map(\.name).joined(separator: ", ")); Central and North) send \(crowdRequests): 1 NEA request and 1 WAQI request per station, all five live")

let reuseSuite = scratch()
DayStore(defaults: reuseSuite).save(fullYesterday, keeping: [stubToday, stubYesterday])
let reuseFeed = AirFeed(session: crowdSession([stubToday: serveMorning], latency: 0), token: stationToken, defaults: reuseSuite)
_ = await reuseFeed.barogram(.central, now: stubNow)
let openingRequests = Stub.takeAll()
let reused = await reuseFeed.barogram(.central, now: stubNow.addingTimeInterval(3 * 60 + 59))
let reusedRequests = Stub.takeAll()
let expired = await reuseFeed.barogram(.central, now: stubNow.addingTimeInterval(4 * 60))
let expiredRequests = Stub.takeAll()
check(openingRequests == ["nea \(stubToday.iso)", "waqi @1666"], "the first barogram sends \(openingRequests)")
check(reusedRequests.isEmpty && reused.observation.snapshot.psi == liveMorning && reused.observation.snapshot.aqi.report != nil, "3 min 59 s later a barogram reuses both bodies from the store: \(reusedRequests.count) requests, PSI and AQI live")
check(expiredRequests == openingRequests && expired.observation.snapshot.psi == liveMorning, "at 4 min the reuse window has closed: the barogram sends \(expiredRequests) once each")

let policyAQI = AQIReport(aqi: 120, station: "Central, Singapore", observedAt: stubNow)
let policyTrend = expectedTrend(morning, fullYesterday)

func policyCase(ago: TimeInterval, _ freshness: Freshness, aqi: Feed<AQIReport> = .live(policyAQI), psiMissing: Bool = false, trend: Feed<PSITrend> = policyTrend) -> Barogram {
    let psi: Feed<PSIReport> = psiMissing ? .unavailable(.unreadable) : .live(PSIReport(psi: morning.hours[9].psi, observedAt: stubNow.addingTimeInterval(-ago)))
    return Barogram(observation: Observation(snapshot: Snapshot(region: .central, psi: psi, aqi: aqi, fetchedAt: stubNow), freshness: freshness), trend: trend)
}

let policyRows: [(String, Barogram, TimeInterval)] = [
    ("fresh: fetched, 10 min old", policyCase(ago: 10 * 60, .fetched), 15 * 60),
    ("near-stale: fetched, 1 h 55 min old", policyCase(ago: 115 * 60, .fetched), 6 * 60),
    ("held-fresh: held, 30 min old", policyCase(ago: 30 * 60, .held), 5 * 60),
    ("held-old: held, 3 h old", policyCase(ago: 180 * 60, .held), 5 * 60),
    ("stale: fetched, NEA silent for 2 h 10 min", policyCase(ago: 130 * 60, .fetched), 5 * 60),
    ("AQI offline", policyCase(ago: 10 * 60, .fetched, aqi: .unavailable(.offline)), 5 * 60),
    ("AQI unreadable", policyCase(ago: 10 * 60, .fetched, aqi: .unavailable(.unreadable)), 5 * 60),
    ("missing token: AQI unavailable, PSI fresh", policyCase(ago: 10 * 60, .fetched, aqi: .unavailable(.missingToken)), 15 * 60),
    ("PSI unavailable, nothing held", policyCase(ago: 0, .fetched, psiMissing: true), 5 * 60),
    ("trend unavailable", policyCase(ago: 10 * 60, .fetched, trend: .unavailable(.offline)), 5 * 60),
]
for (name, barogram, expected) in policyRows {
    let wait = Refresh.nextReload(for: barogram, now: stubNow).timeIntervalSince(stubNow)
    check(wait == expected, "policy \(name): reload in \(Int(wait) / 60) min \(Int(wait) % 60) s")
}

func timeMark(ago: TimeInterval, _ freshness: Freshness) -> Reading.TimeMark {
    let psi = PSIReport(psi: morning.hours[9].psi, observedAt: stubNow.addingTimeInterval(-ago))
    let snapshot = Snapshot(region: .central, psi: .live(psi), aqi: .unavailable(.missingToken), fetchedAt: stubNow)
    return Reading(Observation(snapshot: snapshot, freshness: freshness), now: stubNow).time
}

func clock(ago: TimeInterval) -> String { SGT.clock(stubNow.addingTimeInterval(-ago)) }

check(timeMark(ago: 30 * 60, .held) == .fresh(clock(ago: 30 * 60)), "a held reading 30 min old renders \(timeMark(ago: 30 * 60, .held)), not STALE")
check(timeMark(ago: 119 * 60, .held) == .fresh(clock(ago: 119 * 60)), "a held reading 1 h 59 min old renders \(timeMark(ago: 119 * 60, .held)), not STALE")
check(timeMark(ago: 121 * 60, .held) == .stale("STALE " + clock(ago: 121 * 60)), "a held reading 2 h 1 min old renders \(timeMark(ago: 121 * 60, .held))")
check(timeMark(ago: 121 * 60, .fetched) == .stale("STALE " + clock(ago: 121 * 60)), "a fetched reading 2 h 1 min old renders \(timeMark(ago: 121 * 60, .fetched))")
check(timeMark(ago: 21 * 3600, .fetched) == .stale("STALE " + SGT.day(stubNow.addingTimeInterval(-21 * 3600))), "a reading 21 h old renders \(timeMark(ago: 21 * 3600, .fetched))")

await paceNEA()
let liveSuite = scratch()
let liveBarogram = await AirFeed(token: nil, defaults: liveSuite).barogram(.central)
check(liveBarogram.observation.snapshot.aqi == .unavailable(.missingToken), "live barogram without a token has AQI .unavailable(.missingToken)")
if let newest = dayFeedNewest {
    let observation = liveBarogram.observation
    check(observation.freshness == .fetched && observation.snapshot.psi == .live(report(newest)), "live barogram(.central) PSI is live and equals the day feed's newest hour: central \(observation.snapshot.psi.report?.psi[.central].map(String.init) ?? "-") at \(newest.hour.formatted(sgtFormat))")
}
if let liveTrend = liveBarogram.trend.report {
    check(liveTrend.hours.count <= 24 && ascending(liveTrend.hours), "live barogram trend is .live: \(liveTrend.hours.count) hours, \(liveTrend.hours[0].hour.formatted(sgtFormat)) to \(liveTrend.newest.hour.formatted(sgtFormat))")
} else {
    check(false, "live barogram trend is \(liveBarogram.trend)")
}
let liveDays = DayStore(defaults: liveSuite)
check(liveDays.load(yesterday)?.isComplete == true && liveDays.load(today) != nil, "live barogram cached today and a complete yesterday")

UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
check(UserDefaults(suiteName: suite)?.dictionaryRepresentation().keys.contains { $0.hasPrefix("snapshot.") || $0.hasPrefix("psi.") || $0.hasPrefix("recent.") } == false, "scratch defaults suite emptied")

print(failures == 0 ? "All feed checks passed." : "\(failures) feed check(s) failed.")
exit(failures == 0 ? 0 : 1)
