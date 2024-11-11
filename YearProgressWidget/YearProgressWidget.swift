// YearProgressWidget
// authored by issa euceph
// november 11, 2024

import WidgetKit
import SwiftUI

struct YearPercentageWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "YearPercentageWidget",
            provider: YearPercentageProvider()
        ) { entry in
            YearPercentageWidgetView(entry: entry)
        }
        .configurationDisplayName("khatm")
        .description("shows the percentage of your year completed or remaining")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct YearPercentageEntry: TimelineEntry {
    let date: Date
    let showRemaining: Bool
}

struct YearPercentageProvider: TimelineProvider {
    func placeholder(in context: Context) -> YearPercentageEntry {
        YearPercentageEntry(date: Date(), showRemaining: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (YearPercentageEntry) -> Void) {
        let entry = YearPercentageEntry(date: Date(), showRemaining: true)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<YearPercentageEntry>) -> Void) {
        let entry = YearPercentageEntry(date: Date(), showRemaining: true)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct YearPercentageWidgetView: View {
    let entry: YearPercentageEntry
    
    var percentage: Double {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: entry.date)
        let startOfYear = calendar.date(from: DateComponents(year: year))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1))!
        
        let totalDays = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day!
        let daysPassed = calendar.dateComponents([.day], from: startOfYear, to: entry.date).day!
        
        let percentagePassed = Double(daysPassed) / Double(totalDays) * 100
        return entry.showRemaining ? (100 - percentagePassed) : percentagePassed
    }
    
    var body: some View {
        Text(String(format: "%.2f%%", percentage))
            .font(.system(size: 300, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .containerBackground(.opacity(0.8), for: .widget)
    }
}

#Preview("Remaining", as: .accessoryRectangular) {
    YearPercentageWidget()
} timeline: {
    YearPercentageEntry(date: Date(), showRemaining: true)
}

#Preview("Elapsed", as: .accessoryRectangular) {
    YearPercentageWidget()
} timeline: {
    YearPercentageEntry(date: Date(), showRemaining: false)
}
