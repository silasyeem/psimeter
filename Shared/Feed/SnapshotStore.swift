import Foundation

struct SnapshotStore: Sendable {
    static let standard = SnapshotStore(defaults: .standard)

    // UserDefaults is documented as thread-safe but the SDK does not mark it Sendable.
    private nonisolated(unsafe) let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load(_ region: Region) -> Snapshot? {
        guard let data = defaults.data(forKey: key(region)) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    func save(_ snapshot: Snapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key(snapshot.region))
    }

    private func key(_ region: Region) -> String {
        "snapshot.\(region.rawValue)"
    }
}
