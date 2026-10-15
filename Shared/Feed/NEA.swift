import Foundation

enum NEA {
    static let endpoint = URL(string: "https://api-open.data.gov.sg/v2/real-time/api/psi")!

    static func url(for day: SGTDay) -> URL {
        endpoint.appending(queryItems: [URLQueryItem(name: "date", value: day.iso)])
    }

    static func decodeDay(_ data: Data, day: SGTDay) throws(FeedFailure) -> PSIDay {
        let items = try JSONDecoder.decodeFeed(Response.self, from: data).data.items
        var byHour: [Date: PSIHour] = [:]
        for item in items {
            // An hour outside the requested day means the reply is not that day, and would make `isComplete` lie.
            guard SGTDay(containing: item.timestamp) == day else { throw .unreadable }
            guard byHour[item.timestamp].map({ $0.observedAt < item.updatedTimestamp }) ?? true else { continue }
            byHour[item.timestamp] = PSIHour(hour: item.timestamp, observedAt: item.updatedTimestamp, psi: item.readings.psi.byRegion)
        }
        return PSIDay(day: day, hours: byHour.values.sorted { $0.hour < $1.hour })
    }

    private struct Response: Decodable {
        let data: Payload

        struct Payload: Decodable {
            let items: [Item]
        }

        struct Item: Decodable {
            let timestamp: Date
            let updatedTimestamp: Date
            let readings: Readings
        }

        struct Readings: Decodable {
            let psi: Regional

            enum CodingKeys: String, CodingKey {
                case psi = "psi_twenty_four_hourly"
            }
        }

        struct Regional: Decodable {
            let north, south, east, west, central: Int

            var byRegion: [Region: Int] {
                [.north: north, .south: south, .east: east, .west: west, .central: central]
            }
        }
    }
}
