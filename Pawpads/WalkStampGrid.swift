import SwiftUI
import CoreData

struct WalkStampGrid: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: true)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    let calendarMatrix = DateUtils.generateCalendarMatrix()
    let cellSize: CGFloat = 24

    var body: some View {
        VStack(spacing: 6) {
            ForEach(calendarMatrix, id: \.self) { week in
                HStack(spacing: 15) {
                    ForEach(week, id: \.self) { date in
                        if let date = date {
                            StampCellView(date: date, isWalked: didWalk(on: date), cellSize: cellSize)
                        } else {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func didWalk(on date: Date) -> Bool {
        walkLogs.contains { log in
            if let logDate = log.date {
                return Calendar.current.isDate(logDate, inSameDayAs: date)
            }
            return false
        }
    }
}
