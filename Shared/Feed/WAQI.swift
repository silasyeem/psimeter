import Foundation

enum WAQI {
    private static let base = URL(string: "https://api.waqi.info")!

    static func url(for region: Region, token: WAQIToken) -> URL {
        base
            .appending(path: "feed/@\(region.waqiStation)/")
            .appending(queryItems: [URLQueryItem(name: "token", value: token.value)])
    }

    static func decode(_ data: Data) throws(FeedFailure) -> AQIReport {
        // An error reply is HTTP 200 with `data` as a bare string, so the status decides whether `data` is a station.
        guard try JSONDecoder.decodeFeed(Status.self, from: data).status == "ok" else { throw .unreadable }
        let station = try JSONDecoder.decodeFeed(Response.self, from: data).data
        return AQIReport(aqi: station.aqi, station: station.city.name, observedAt: station.time.iso)
    }

    private struct Status: Decodable {
        let status: String
    }

    private struct Response: Decodable {
        let data: Station

        struct Station: Decodable {
            let aqi: Int
            let city: City
            let time: Time
        }

        struct City: Decodable {
            let name: String
        }

        struct Time: Decodable {
            let iso: Date
        }
    }
}
