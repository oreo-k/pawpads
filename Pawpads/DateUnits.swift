import Foundation

struct DateUtils {
    
    /// 今日を含む直近7週間分のマトリクス（各週7日分、月曜始まり）を返す
    static func generateCalendarMatrix() -> [[Date?]] {
        let calendar = Calendar.current
        let today = Date()
        let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        var matrix: [[Date?]] = []

        for weekOffset in (0..<5).reversed() {  // 古い週から新しい週へ（上→下）
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisWeekStart) else { continue }

            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    // 今日より未来の日は nil（空欄）にする
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

    /// 同じ日かを比較（年月日だけ）
    static func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(d1, inSameDayAs: d2)
    }
}
