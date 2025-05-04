import Foundation

struct DateUtils {
    static func generateCalendarMatrix() -> [[Date?]] {
        let calendar: Calendar = {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // 日曜始まり
            return calendar
        }()

        let today = Date()
        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        var matrix: [[Date?]] = []

        for weekOffset in (0..<5).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisWeekStart) else { continue }

            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    if day > today {
                        week.append(nil)
                    } else {
                        week.append(day)
                    }
                }
            }
            matrix.append(week)
        }

    return matrix
    }

    static func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }
}
