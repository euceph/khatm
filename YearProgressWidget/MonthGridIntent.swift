import WidgetKit
import SwiftUI
import AppIntents

enum MonthGridDisplayOption: String, Codable {
    case daysLeft
    case daysPassed
}

struct MonthGridOptionEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Month Grid Display Option"
    }
    
    static var defaultQuery = MonthGridEntityQuery()
    
    var id: String
    var displayOption: MonthGridDisplayOption

    var displayRepresentation: DisplayRepresentation {
        switch displayOption {
        case .daysLeft:
            return DisplayRepresentation(
                title: "days left",
                subtitle: "show how many days are left in the month"
            )
        case .daysPassed:
            return DisplayRepresentation(
                title: "days passed",
                subtitle: "show how many days have passed in the month"
            )
        }
    }
}

struct MonthGridEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [MonthGridOptionEntity] {
        return identifiers.compactMap { id in
            guard let option = MonthGridDisplayOption(rawValue: id) else { return nil }
            return MonthGridOptionEntity(id: id, displayOption: option)
        }
    }
    
    func suggestedEntities() -> [MonthGridOptionEntity] {
        return [
            MonthGridOptionEntity(id: "daysLeft", displayOption: .daysLeft),
            MonthGridOptionEntity(id: "daysPassed", displayOption: .daysPassed)
        ]
    }
}

struct MonthGridIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Month Grid Display"
    static var description: IntentDescription = "Choose whether to display days left or days passed in the month."

    @Parameter(title: "perspective")
    var displayOption: MonthGridOptionEntity?

    var resolvedDisplayOption: MonthGridDisplayOption {
        displayOption?.displayOption ?? .daysLeft
    }
}
