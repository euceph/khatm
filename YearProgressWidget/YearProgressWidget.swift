import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            progressOptionEntity: YearProgressOptionEntity(id: "elapsed", displayOption: .elapsed),
            decimalPlaces: 3
        )
    }

    func snapshot(for configuration: YearProgressIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            progressOptionEntity: configuration.resolvedProgressOption,
            decimalPlaces: configuration.decimalPlaces
        )
    }

    func timeline(for configuration: YearProgressIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let entries = stride(from: 0, through: 60, by: 5).map { minuteOffset in
            let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            return SimpleEntry(
                date: entryDate,
                progressOptionEntity: configuration.resolvedProgressOption,
                decimalPlaces: configuration.decimalPlaces
            )
        }
        
        let nextUpdate = calendar.date(byAdding: .minute, value: 5, to: entries.last?.date ?? currentDate)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let progressOptionEntity: YearProgressOptionEntity
    let decimalPlaces: Int
    
    var percentage: Double {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1))!
        
        let totalSeconds = endOfYear.timeIntervalSince(startOfYear)
        let elapsedSeconds = date.timeIntervalSince(startOfYear)
        let elapsedPercentage = (elapsedSeconds / totalSeconds) * 100
        
        return progressOptionEntity.displayOption == .elapsed ? elapsedPercentage : (100 - elapsedPercentage)
    }
}

struct YearProgressWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            accessoryRectangularView
        case .accessoryCircular:
            accessoryCircularView
        default:
            Text("unsupported")
        }
    }

    private var accessoryRectangularView: some View {
        Text(String(format: "%.\(entry.decimalPlaces)f%%", entry.percentage))
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .containerBackground(.clear, for: .widget)
    }

    private var accessoryCircularView: some View {
        ZStack {
            Gauge(value: entry.percentage, in: 0...100) {
                EmptyView()
            }
            .gaugeStyle(.accessoryCircular)
            
            Text(String(format: "%.0f%%", entry.percentage))
                .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct YearProgressWidget: Widget {
    let kind: String = "YearProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: YearProgressIntent.self,
            provider: Provider()
        ) { entry in
            YearProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("percentage")
        .description("shows the percentage of your year elapsed or remaining")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular])
    }
}

#Preview("Year Progress Widget", as: .accessoryRectangular) {
    YearProgressWidget()
} timeline: {
        SimpleEntry(
            date: .now,
            progressOptionEntity: YearProgressOptionEntity(id: "remaining", displayOption: .remaining),
            decimalPlaces: 3
        )
}

#Preview("Circular Preview", as: .accessoryCircular) {
    YearProgressWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        progressOptionEntity: YearProgressOptionEntity(id: "elapsed", displayOption: .elapsed),
        decimalPlaces: 3
    )
}

#Preview("Live Updates", as: .accessoryRectangular) {
    YearProgressWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 15, by: 5).compactMap { minuteOffset in
        calendar.date(byAdding: .minute, value: minuteOffset, to: .now)
    }
    return dates.map { date in
        SimpleEntry(
            date: date,
            progressOptionEntity: YearProgressOptionEntity(id: "remaining", displayOption: .remaining),
            decimalPlaces: 3
        )
    }
}
