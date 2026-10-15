import Foundation

enum Source: Hashable, Sendable {
    case psiDay(SGTDay)
    case station(Region)

    var key: String {
        switch self {
        case .psiDay(let day): "nea.\(day.iso)"
        case .station(let region): "waqi.\(region.waqiStation)"
        }
    }
}

/// Every widget instance in the extension shares this, so one refresh wave sends each source one request.
actor Flights {
    static let shared = Flights()

    private var running: [Source: Task<Result<Data, FeedFailure>, Never>] = [:]

    func run(_ source: Source, _ fetch: @escaping @Sendable () async -> Result<Data, FeedFailure>) async -> Result<Data, FeedFailure> {
        if let flight = running[source] { return await flight.value }
        let flight = Task { await fetch() }
        running[source] = flight
        let result = await flight.value
        running[source] = nil
        return result
    }
}
