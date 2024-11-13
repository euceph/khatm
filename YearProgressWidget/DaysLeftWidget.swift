//
//  DaysLeftWidget.swift
//  khatm
//
//  Created by issa euceph on 11/13/24.
//

import WidgetKit
import SwiftUI

struct DaysLeftProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DaysLeftEntry {
        DaysLeftEntry(date: Date(), displayOption: .daysLeft)
    }

    func snapshot(for configuration: DaysLeftIntent, in context: Context) async -> DaysLeftEntry {
        DaysLeftEntry(date: Date(), displayOption: configuration.resolvedDisplayOption)
    }

    func timeline(for configuration: DaysLeftIntent, in context: Context) async -> Timeline<DaysLeftEntry> {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let nextUpdate = calendar.startOfDay(for: currentDate).addingTimeInterval(24 * 60 * 60)
        let entry = DaysLeftEntry(date: currentDate, displayOption: configuration.resolvedDisplayOption)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}


struct DaysLeftEntry: TimelineEntry {
    let date: Date
    let displayOption: DaysDisplayOption

    var daysLeft: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: endOfYear).day ?? 0
    }

    var daysPassed: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        return calendar.dateComponents([.day], from: startOfYear, to: calendar.startOfDay(for: date)).day ?? 0
    }

    var displayDays: Int {
        switch displayOption {
        case .daysLeft:
            return daysLeft
        case .daysPassed:
            return daysPassed
        }
    }
}

struct DaysLeftWidgetEntryView: View {
    var entry: DaysLeftEntry

    var body: some View {
        ZStack {
            HStack {
                Text("\(entry.displayDays)")
                    .font(.system(size: 50, weight: .bold, design: .default))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 0) {
                    Text("days")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                    Text(entry.displayOption == .daysLeft ? "left" : "passed")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 10)
        }
        .containerBackground(.clear, for: .widget)
    }
}



struct DaysLeftWidget: Widget {
    let kind: String = "DaysLeftWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: DaysLeftIntent.self,
            provider: DaysLeftProvider()
        ) { entry in
            DaysLeftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("days left")
        .description("the number of days left in your year")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview("Days Left Widget", as: .accessoryRectangular) {
    DaysLeftWidget()
} timeline: {
    DaysLeftEntry(date: .now, displayOption: .daysLeft)
}

#Preview("Days Left Specific Date", as: .accessoryRectangular) {
    DaysLeftWidget()
} timeline: {
    DaysLeftEntry(date: DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date ?? .now, displayOption: .daysLeft)
}

#Preview("Live Update Preview - Days Left", as: .accessoryRectangular) {
    DaysLeftWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 45, by: 15).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: .now)
    }
    return dates.map { date in
        DaysLeftEntry(date: date, displayOption: .daysLeft)
    }
}

#Preview("Live Update Preview - Days Passed", as: .accessoryRectangular) {
    DaysLeftWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 45, by: 15).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: .now)
    }
    return dates.map { date in
        DaysLeftEntry(date: date, displayOption: .daysPassed)
    }
}
