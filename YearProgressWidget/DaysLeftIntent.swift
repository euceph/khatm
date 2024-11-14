import WidgetKit
import SwiftUI
import AppIntents

enum DaysDisplayOption: String, Codable {
    case daysLeft
    case daysPassed
}

struct DaysLeftOptionEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Days Left Display Option"
    }
    
    static var defaultQuery = DaysLeftEntityQuery()
    
    var id: String
    var displayOption: DaysDisplayOption

    var displayRepresentation: DisplayRepresentation {
        switch displayOption {
        case .daysLeft:
            return DisplayRepresentation(
                title: "days left",
                subtitle: "show how many days are left in the year"
            )
        case .daysPassed:
            return DisplayRepresentation(
                title: "days passed",
                subtitle: "show how many days have passed in the year"
            )
        }
    }
}

struct DaysLeftEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [DaysLeftOptionEntity] {
        return identifiers.compactMap { id in
            guard let option = DaysDisplayOption(rawValue: id) else { return nil }
            return DaysLeftOptionEntity(id: id, displayOption: option)
        }
    }
    
    func suggestedEntities() -> [DaysLeftOptionEntity] {
        return [
            DaysLeftOptionEntity(id: "daysLeft", displayOption: .daysLeft),
            DaysLeftOptionEntity(id: "daysPassed", displayOption: .daysPassed)
        ]
    }
}

struct DaysLeftIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Days Left Display"
    static var description: IntentDescription = "Choose whether to display days left or days passed in the year."

    @Parameter(title: "perspective")
    var displayOption: DaysLeftOptionEntity?

    var resolvedDisplayOption: DaysDisplayOption {
        displayOption?.displayOption ?? .daysLeft
    }
}
