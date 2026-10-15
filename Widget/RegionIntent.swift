import AppIntents
import WidgetKit

struct RegionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Region"
    static let description = IntentDescription("Choose the region whose 24-hour PSI the counter shows. The bezel always shows north, east, south and west.")

    @Parameter(title: "Region", default: .central)
    var region: Region
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
