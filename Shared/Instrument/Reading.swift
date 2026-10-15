import Foundation

struct Reading: Sendable {
    enum TimeMark: Equatable, Sendable {
        case none
        case fresh(String)
        case stale(String)
    }

    let region: Region
    let psi: Int?
    let psiLabel: String
    let aqi: Int?
    let aqiLabel: String
    let bezel: [Region: Int]
    let time: TimeMark

    init(_ observation: Observation, now: Date) {
        let snapshot = observation.snapshot
        region = snapshot.region
        let regionMark = snapshot.region.rawValue.uppercased()

        switch snapshot.psi {
        case .live(let report):
            psi = report.psi[snapshot.region]
            psiLabel = psi == nil ? "PSI · \(FeedFailure.unreadable.engraving)" : "PSI · 24H · \(regionMark)"
            bezel = report.psi
            let age = now.timeIntervalSince(report.observedAt)
            if observation.freshness == .held || age > PSIReport.staleAfter {
                time = .stale("STALE " + (age > 20 * 60 * 60 ? SGT.day(report.observedAt) : SGT.clock(report.observedAt)))
            } else {
                time = .fresh(SGT.clock(report.observedAt))
            }
        case .unavailable(let failure):
            psi = nil
            psiLabel = "PSI · \(failure.engraving)"
            bezel = [:]
            time = .none
        }

        switch snapshot.aqi {
        case .live(let report):
            aqi = report.aqi
            aqiLabel = "AQI · WAQI"
        case .unavailable(let failure):
            aqi = nil
            aqiLabel = "AQI · \(failure.engraving)"
        }
    }

    var needleValue: Int {
        min(max(psi ?? 0, Scale.psiDial.lowerBound), Scale.psiDial.upperBound)
    }

    var band: Band? { psi.map(Scale.psi.band(for:)) }

    var headline: String {
        "PSI \(psi.map(String.init) ?? "–") · AQI \(aqi.map(String.init) ?? "–")"
    }

    var detail: String {
        guard let band else {
            return "\(region.name) · \(psiLabel.replacingOccurrences(of: "PSI · ", with: "").capitalized)"
        }
        switch time {
        case .none: return "\(region.name) · \(band.name)"
        case .fresh(let clock): return "\(region.name) · \(band.name) · \(clock)"
        case .stale(let mark): return "\(region.name) · \(band.name) · \(mark.capitalized)"
        }
    }

    var spoken: String {
        var parts: [String] = []
        if let psi, let band {
            parts.append("24-hour PSI \(psi), \(region.name), \(band.name)")
        } else {
            parts.append(psiLabel.replacingOccurrences(of: " · ", with: " "))
        }
        if let aqi {
            parts.append("WAQI AQI \(aqi), \(Scale.aqi.band(for: aqi).name)")
        } else {
            parts.append(aqiLabel.replacingOccurrences(of: " · ", with: " "))
        }
        switch time {
        case .none: break
        case .fresh(let clock): parts.append("observed \(clock)")
        case .stale(let mark): parts.append(mark.lowercased())
        }
        return parts.joined(separator: ". ")
    }
}

extension FeedFailure {
    var engraving: String {
        switch self {
        case .missingToken: "UNAVAILABLE"
        case .offline: "OFFLINE"
        case .unreadable: "NO DATA"
        }
    }
}

enum SGT {
    static let timeZone = TimeZone(identifier: "Asia/Singapore") ?? TimeZone(secondsFromGMT: 8 * 3600)!

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    static func clock(_ date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
    }

    static func day(_ date: Date) -> String {
        let parts = calendar.dateComponents([.day, .month], from: date)
        let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        return "\(parts.day ?? 0) \(months[((parts.month ?? 1) - 1) % 12])"
    }
}
