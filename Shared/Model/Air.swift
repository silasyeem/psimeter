import Foundation

enum Region: String, CaseIterable, Codable, CodingKeyRepresentable, Sendable {
    case central, north, east, south, west

    var name: String { rawValue.capitalized }

    var waqiStation: Int {
        switch self {
        case .north: 1662
        case .south: 1663
        case .east: 1664
        case .west: 1665
        case .central: 1666
        }
    }
}

struct PSIReport: Codable, Equatable, Sendable {
    static let staleAfter: TimeInterval = 2 * 60 * 60

    let psi: [Region: Int]
    let observedAt: Date
}

struct AQIReport: Codable, Equatable, Sendable {
    let aqi: Int
    let station: String
    let observedAt: Date
}

enum FeedFailure: String, Codable, Equatable, Sendable, Error {
    case missingToken, offline, unreadable
}

enum Feed<Report: Sendable>: Sendable {
    case live(Report)
    case unavailable(FeedFailure)

    var report: Report? {
        if case .live(let report) = self { report } else { nil }
    }
}

extension Feed: Equatable where Report: Equatable {}
extension Feed: Codable where Report: Codable {}

struct Snapshot: Codable, Equatable, Sendable {
    let region: Region
    let psi: Feed<PSIReport>
    let aqi: Feed<AQIReport>
    let fetchedAt: Date
}

/// `held` means this fetch failed and the snapshot is the last good one from the cache.
enum Freshness: Equatable, Sendable {
    case fetched, held
}

struct Observation: Equatable, Sendable {
    let snapshot: Snapshot
    let freshness: Freshness
}

struct SGTDay: Hashable, Comparable, Codable, Sendable {
    static let timeZone = TimeZone(identifier: "Asia/Singapore") ?? TimeZone(secondsFromGMT: 8 * 3600)!

    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(containing date: Date) {
        let parts = Self.calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 1970, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    var start: Date {
        Self.calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    var previous: SGTDay {
        SGTDay(containing: start.addingTimeInterval(-12 * 60 * 60))
    }

    var iso: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func < (lhs: SGTDay, rhs: SGTDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}

/// One NEA hourly item: `hour` is the item's `timestamp`, `observedAt` its `updatedTimestamp`.
struct PSIHour: Codable, Equatable, Sendable {
    let hour: Date
    let observedAt: Date
    let psi: [Region: Int]
}

struct PSIDay: Codable, Equatable, Sendable {
    let day: SGTDay
    let hours: [PSIHour]

    var isComplete: Bool { hours.count == 24 }
}

struct PSITrend: Equatable, Sendable {
    static let span: TimeInterval = 24 * 60 * 60

    let hours: [PSIHour]

    init?(days: [PSIDay]) {
        var byHour: [Date: PSIHour] = [:]
        for hour in days.flatMap(\.hours) where byHour[hour.hour].map({ $0.observedAt < hour.observedAt }) ?? true {
            byHour[hour.hour] = hour
        }
        let ascending = byHour.values.sorted { $0.hour < $1.hour }
        guard let newest = ascending.last else { return nil }
        let window = ascending.filter { $0.hour > newest.hour.addingTimeInterval(-Self.span) }
        guard window.count >= 2 else { return nil }
        hours = window
    }

    var newest: PSIHour { hours[hours.count - 1] }
    var start: Date { newest.hour.addingTimeInterval(-Self.span) }

    func points(_ region: Region) -> [(hour: Date, psi: Int)] {
        hours.compactMap { hour in hour.psi[region].map { (hour.hour, $0) } }
    }
}

struct Barogram: Equatable, Sendable {
    let observation: Observation
    let trend: Feed<PSITrend>
}
