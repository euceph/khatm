import WidgetKit
import AppIntents

enum YearProgressOption: String, Codable {
    case elapsed
    case remaining
}

struct YearProgressOptionEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Year Progress Option"
    }
    
    static var defaultQuery = YearProgressEntityQuery()
    
    var id: String
    var displayOption: YearProgressOption

    var displayRepresentation: DisplayRepresentation {
        switch displayOption {
        case .elapsed:
            return DisplayRepresentation(
                title: "Year Elapsed",
                subtitle: "Displays the percentage of the year that has passed"
            )
        case .remaining:
            return DisplayRepresentation(
                title: "Year Remaining",
                subtitle: "Displays the percentage of the year left"
            )
        }
    }
}

struct YearProgressEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [YearProgressOptionEntity] {
        return identifiers.compactMap { id in
            guard let option = YearProgressOption(rawValue: id) else { return nil }
            return YearProgressOptionEntity(id: id, displayOption: option)
        }
    }
    
    func suggestedEntities() -> [YearProgressOptionEntity] {
        return [
            YearProgressOptionEntity(id: "elapsed", displayOption: .elapsed),
            YearProgressOptionEntity(id: "remaining", displayOption: .remaining)
        ]
    }
}

struct YearProgressIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Year Progress"
    static var description: IntentDescription = "Choose whether to display elapsed or remaining year progress."

    @Parameter(title: "Display")
    var progressOption: YearProgressOptionEntity?
    
    var resolvedProgressOption: YearProgressOptionEntity {
        progressOption ?? YearProgressOptionEntity(id: "remaining", displayOption: .remaining)
    }
}


