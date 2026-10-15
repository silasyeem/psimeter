import Foundation

extension JSONDecoder {
    static func decodeFeed<T: Decodable>(_ type: T.Type, from data: Data) throws(FeedFailure) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            // Older runtimes reject fractional seconds unless asked for them, and reject whole seconds when asked.
            guard let date = (try? Date(text, strategy: .iso8601))
                ?? (try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)))
            else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not an ISO 8601 timestamp")
            }
            return date
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw .unreadable
        }
    }
}
