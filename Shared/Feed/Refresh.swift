import Foundation

enum Refresh {
    static let routine: TimeInterval = 15 * 60
    static let retry: TimeInterval = 5 * 60
    /// A minute past the 2-hour mark, so the reload lands after the face has turned stale, never just before.
    static let staleMargin: TimeInterval = 60

    static func turnsStale(_ psi: PSIReport) -> Date {
        psi.observedAt.addingTimeInterval(PSIReport.staleAfter + staleMargin)
    }

    static func nextReload(for barogram: Barogram, now: Date) -> Date {
        let observation = barogram.observation
        guard observation.freshness == .fetched,
              case .live(let psi) = observation.snapshot.psi,
              !psi.isStale(at: now),
              case .live = barogram.trend,
              !failed(observation.snapshot.aqi)
        else { return now.addingTimeInterval(retry) }
        return min(now.addingTimeInterval(routine), turnsStale(psi))
    }

    private static func failed(_ aqi: Feed<AQIReport>) -> Bool {
        switch aqi {
        case .live, .unavailable(.missingToken): false
        case .unavailable(.offline), .unavailable(.unreadable): true
        }
    }
}
