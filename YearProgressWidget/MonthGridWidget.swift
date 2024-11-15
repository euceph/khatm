import WidgetKit
import SwiftUI

struct MonthGridProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MonthGridEntry {
        MonthGridEntry(date: Date(), displayOption: .daysLeft, shape: .square)
    }
    
    func snapshot(for configuration: MonthGridIntent, in context: Context) async -> MonthGridEntry {
        MonthGridEntry(date: Date(), displayOption: configuration.resolvedDisplayOption, shape: configuration.resolvedShape)
    }
    
    func timeline(for configuration: MonthGridIntent, in context: Context) async -> Timeline<MonthGridEntry> {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let nextUpdate = calendar.startOfDay(for: currentDate).addingTimeInterval(24 * 60 * 60)
        let entry = MonthGridEntry(date: currentDate, displayOption: configuration.resolvedDisplayOption, shape: configuration.resolvedShape)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct MonthGridEntry: TimelineEntry {
    let date: Date
    let displayOption: MonthGridDisplayOption
    let shape: MonthGridShape
    
    var monthDays: [Date] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        
        return range.compactMap { day -> Date? in
            calendar.date(from: DateComponents(year: calendar.component(.year, from: date),
                                               month: calendar.component(.month, from: date),
                                               day: day))
        }
    }
    
    var daysLeftInMonth: String {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let lastDay = range.upperBound - 1
        let currentDay = calendar.component(.day, from: date)
        
        switch displayOption {
        case .daysLeft:
            return "\(lastDay - currentDay + 1)"
        case .daysPassed:
            return "\(currentDay)"
        }
    }
    
    var displayText: String {
        switch displayOption {
        case .daysLeft:
            return "left"
        case .daysPassed:
            return "passed"
        }
    }
}

struct DayCell: View {
    let date: Date
    let currentDate: Date
    let displayOption: MonthGridDisplayOption
    let shape: MonthGridShape
    let size: CGFloat
    
    var body: some View {
        let calendar = Calendar.current
        let isPast = calendar.compare(date, to: currentDate, toGranularity: .day) == .orderedAscending
        let isToday = calendar.isDate(date, inSameDayAs: currentDate)
        
        RoundedRectangle(cornerRadius: shape == .square ? 1.5 : 8)
            .fill(isToday ? Color.red.opacity(0.9) :
                    displayOption == .daysPassed ?
                  (isPast ? .white : .white.opacity(0.3)) :
                    (isPast ? .white.opacity(0.3) : .white))
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
    }
}

struct MonthGridEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MonthGridEntry
    
    var body: some View {
        if family == .accessoryRectangular {
            let dayWidth: CGFloat = 10
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    let weeks = createWeekArrays(from: entry.monthDays)
                    
                    ForEach(weeks, id: \.self) { week in
                        HStack(spacing: 2) {
                            ForEach(week, id: \.self) { date in
                                if let date = date {
                                    DayCell(date: date,
                                            currentDate: entry.date,
                                            displayOption: entry.displayOption,
                                            shape: entry.shape,
                                            size: dayWidth)
                                } else {
                                    Color.clear.frame(width: dayWidth, height: dayWidth)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                VStack(spacing: -4) {
                    Text("\(entry.daysLeftInMonth)d")
                        .font(.system(size: 48, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                    
                    Text(entry.displayText)
                        .font(.system(size: 15, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.trailing, 4)
            }
        }
    }
    
    func createWeekArrays(from dates: [Date]) -> [[Date?]] {
        let calendar = Calendar.current
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []
        
        guard let firstDate = dates.first else { return [] }
        let weekday = calendar.component(.weekday, from: firstDate)
        
        for _ in 1..<weekday {
            currentWeek.append(nil)
        }
        
        for date in dates {
            currentWeek.append(date)
            
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
}

struct MonthGridWidget: Widget {
    let kind: String = "MonthGridWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MonthGridIntent.self,
            provider: MonthGridProvider()
        ) { entry in
            MonthGridEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .supportedFamilies([.accessoryRectangular])
        .configurationDisplayName("month grid")
        .description("display the days in the current month as a grid")
    }
}

#Preview("Month Grid", as: .accessoryRectangular) {
    MonthGridWidget()
} timeline: {
    MonthGridEntry(date: Date(), displayOption: .daysLeft, shape: .square)
}

#Preview("Month Grid Timeline", as: .accessoryRectangular) {
    MonthGridWidget()
} timeline: {
    let calendar = Calendar.current
    let dates = stride(from: 0, through: 100, by: 10).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: .now)
    }
    return dates.map { date in
        MonthGridEntry(date: date, displayOption: .daysLeft, shape: .circle)
    }
}
