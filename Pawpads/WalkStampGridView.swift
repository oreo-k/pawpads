import SwiftUI
import CoreData

struct WalkStampGridView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: true)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    private let matrix: [[Date?]] = DateUtils.generateCalendarMatrix()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(matrix, id: \.self) { week in
                HStack(spacing: 15) {
                    ForEach(week, id: \.self) { day in
                        if let date = day {
                            let walked = walkLogs.contains { log in
                                if let logDate = log.date {
                                    return DateUtils.isSameDay(logDate, date)
                                }
                                return false
                            }
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(walked ? .brown : .gray.opacity(0.2))
                        } else {
                            // 未来日の空欄
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
        }
    }
}
