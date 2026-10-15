import Foundation

struct RecentStore: Sendable {
    static let standard = RecentStore(defaults: .standard)
    static let window: TimeInterval = 4 * 60

    private static let prefix = "recent."

    // UserDefaults is documented as thread-safe but the SDK does not mark it Sendable.
    private nonisolated(unsafe) let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load(_ source: Source, now: Date) -> Data? {
        guard let entry = entry(Self.prefix + source.key), entry.isRecent(at: now) else { return nil }
        return entry.body
    }

    func save(_ body: Data, for source: Source, at now: Date) {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(Self.prefix) {
            if entry(key)?.isRecent(at: now) != true {
                defaults.removeObject(forKey: key)
            }
        }
        guard let data = try? JSONEncoder().encode(Entry(fetchedAt: now, body: body)) else { return }
        defaults.set(data, forKey: Self.prefix + source.key)
    }

    private func entry(_ key: String) -> Entry? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(Entry.self, from: $0) }
    }

    private struct Entry: Codable {
        let fetchedAt: Date
        let body: Data

        func isRecent(at now: Date) -> Bool {
            (0..<RecentStore.window).contains(now.timeIntervalSince(fetchedAt))
        }
    }
}
