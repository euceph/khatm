//
//  ProgressPillWidget.swift
//  khatm
//
//  Created by issa euceph on 11/13/24.
//

import WidgetKit
import SwiftUI
import AppIntents

struct ProgressPillProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ProgressPillEntry {
        ProgressPillEntry(date: Date(), displayOption: .remaining, decimalPlaces: 3)
    }

    func snapshot(for configuration: YearProgressIntent, in context: Context) async -> ProgressPillEntry {
        ProgressPillEntry(
            date: Date(),
            displayOption: configuration.resolvedProgressOption.displayOption,
            decimalPlaces: configuration.decimalPlaces
        )
    }

    func timeline(for configuration: YearProgressIntent, in context: Context) async -> Timeline<ProgressPillEntry> {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let entries = stride(from: 0, through: 60, by: 5).map { minuteOffset in
            let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            return ProgressPillEntry(
                date: entryDate,
                displayOption: configuration.resolvedProgressOption.displayOption,
                decimalPlaces: configuration.decimalPlaces
            )
        }
        
        let nextUpdate = calendar.date(byAdding: .minute, value: 5, to: entries.last?.date ?? currentDate)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
    
}

struct ProgressPillEntry: TimelineEntry {
    let date: Date
    let displayOption: YearProgressOption
    let decimalPlaces: Int

    private var elapsedPercentage: Double {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0))!
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31, hour: 23, minute: 59, second: 59))!
        
        let totalSeconds = endOfYear.timeIntervalSince(startOfYear) + 1
        let elapsedSeconds = date.timeIntervalSince(startOfYear)
        
        return (elapsedSeconds / totalSeconds) * 100
    }
    
    var displayPercentage: Double {
        displayOption == .elapsed ? elapsedPercentage : (100 - elapsedPercentage)
    }
    
    var progressBarPercentage: Double {
        elapsedPercentage
    }
}

struct ProgressPillWidgetEntryView: View {
    var entry: ProgressPillEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(format: "%.\(entry.decimalPlaces)f%%", entry.displayPercentage))
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 2)
            
            GeometryReader { geometry in
                let totalWidth = geometry.size.width - 10
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: totalWidth)
                        .mask(
                            HStack {
                                Rectangle()
                                    .frame(width: totalWidth * CGFloat(entry.progressBarPercentage / 100))
                                    .alignmentGuide(.leading) { d in d[.leading] }
                                Spacer()
                            }
                        )
                }
                .frame(height: 40)
                .padding(.horizontal, 8)
            }
            .frame(height: 40)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct ProgressPillWidget: Widget {
    let kind: String = "ProgressPillWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: YearProgressIntent.self,
            provider: ProgressPillProvider()
        ) { entry in
            ProgressPillWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("pill percentage")
        .description("chunky pill progress bar with tiny percentage")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview("Progress Pill Elapsed", as: .accessoryRectangular) {
    ProgressPillWidget()
} timeline: {
    ProgressPillEntry(date: .now, displayOption: .elapsed, decimalPlaces: 3)
}

#Preview("Progress Pill Remaining", as: .accessoryRectangular) {
    ProgressPillWidget()
} timeline: {
    ProgressPillEntry(date: .now, displayOption: .remaining, decimalPlaces: 3)
}

#Preview("Progress Pill Elapsed Timeline", as: .accessoryRectangular) {
    ProgressPillWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 60, by: 15).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: .now)
    }
    return dates.map { date in
        ProgressPillEntry(date: date, displayOption: .elapsed, decimalPlaces: 3)
    }
}

#Preview("Progress Pill Remaining Timeline", as: .accessoryRectangular) {
    ProgressPillWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 60, by: 15).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: .now)
    }
    return dates.map { date in
        ProgressPillEntry(date: date, displayOption: .remaining, decimalPlaces: 3)
    }
}
