import Foundation

struct DateUtils {
    static func generateCalendarMatrix() -> [[Date?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        var matrix: [[Date?]] = []

        for weekOffset in (0..<5).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisWeekStart) else { continue }

            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    week.append(day > today ? nil : day)
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
