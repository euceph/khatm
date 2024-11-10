import WidgetKit
import SwiftUI
import AppIntents

struct YearProgressEntry: TimelineEntry {
    let date: Date
    let decimalPlaces: Int
    
    var percentageLeft: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1))!
        
        let totalSeconds = endOfYear.timeIntervalSince(startOfYear)
        let remainingSeconds = endOfYear.timeIntervalSince(date)
        let percentage = (remainingSeconds / totalSeconds) * 100
        
        return String(format: "%.\(decimalPlaces)f%%", percentage)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> YearProgressEntry {
        YearProgressEntry(date: Date(), decimalPlaces: 1)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (YearProgressEntry) -> Void) {
        let entry = YearProgressEntry(date: Date(), decimalPlaces: 1)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<YearProgressEntry>) -> Void) {
        let currentDate = Date()
        let entry = YearProgressEntry(date: currentDate, decimalPlaces: 1)
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        
        let timeline = Timeline(entries: [entry], policy: .after(startOfTomorrow))
        completion(timeline)
    }
}

struct YearProgressWidgetEntryView: View {
    var entry: YearProgressEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Text(entry.percentageLeft)
            .font(.system(size: 400, weight: .bold, design: .rounded))
            
            .minimumScaleFactor(0.1)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .containerBackground(.black.opacity(0.8), for: .widget)
    }
}

struct YearProgressWidgetExtension: Widget {
    private let kind: String = "YearProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YearProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Year Progress")
        .description("Shows the percentage of time left in the current year.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct YearProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressWidgetEntryView(entry: YearProgressEntry(
            date: Date(),
            decimalPlaces: 2
        ))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
