import Foundation

enum MonthGrid {
    static func days(for date: Date, calendar original: Calendar = .current) -> [Date?] {
        var calendar = original
        calendar.firstWeekday = 2
        guard let month = calendar.dateInterval(of: .month, for: date),
              let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        let leading = (calendar.component(.weekday, from: month.start) - 2 + 7) % 7
        var result: [Date?] = Array(repeating: nil, count: leading)
        result += range.map { calendar.date(byAdding: .day, value: $0 - 1, to: month.start) }
        result += Array(repeating: nil, count: 42 - result.count)
        return result
    }
}
