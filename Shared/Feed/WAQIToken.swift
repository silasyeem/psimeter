import Foundation

struct WAQIToken: Sendable {
    let value: String

    init?(_ raw: String?) {
        guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        value = trimmed
    }

    static var bundled: WAQIToken? {
        WAQIToken(Bundle.main.object(forInfoDictionaryKey: "WAQIToken") as? String)
    }
}
