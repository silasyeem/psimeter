import Foundation

struct DayStore: Sendable {
    static let standard = DayStore(defaults: .standard)

    private static let key = "psi.days"

    // UserDefaults is documented as thread-safe but the SDK does not mark it Sendable.
    private nonisolated(unsafe) let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load(_ day: SGTDay) -> PSIDay? {
        stored().first { $0.day == day }
    }

    func save(_ day: PSIDay, keeping recent: Set<SGTDay>) {
        let kept = (stored().filter { $0.day != day.day } + [day])
            .filter { recent.contains($0.day) }
            .sorted { $0.day < $1.day }
        guard let data = try? JSONEncoder().encode(kept) else { return }
        defaults.set(data, forKey: Self.key)
    }

    private func stored() -> [PSIDay] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return (try? JSONDecoder().decode([PSIDay].self, from: data)) ?? []
    }
}
