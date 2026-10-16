import AppIntents
import WidgetKit

struct RegionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Instrument"
    static let description = IntentDescription("Choose the region whose 24-hour PSI the counter shows, and whether the instrument is polished or aged. The bezel always shows north, east, south and west.")

    @Parameter(title: "Region", default: .central)
    var region: Region

    @Parameter(title: "Wear", default: .polished)
    var wear: Wear
}

extension Wear: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Wear"
    static let caseDisplayRepresentations: [Wear: DisplayRepresentation] = [
        .polished: "Polished",
        .aged: "Aged",
    ]
}

extension Region: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Region"
    static let caseDisplayRepresentations: [Region: DisplayRepresentation] = [
        .central: "Central",
        .north: "North",
        .east: "East",
        .south: "South",
        .west: "West",
    ]
}
