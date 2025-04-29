import SwiftUI
import CoreData

struct WalkStampGrid: View {
    let walkLogs: FetchedResults<WalkLog>

    private var last30Days: [Date] {
        let calendar = Calendar.current
        return (0..<30).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(last30Days, id: \.self) { day in
                if hasWalked(on: day) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }
            }
        }
        .padding()
    }

    private func hasWalked(on date: Date) -> Bool {
        let calendar = Calendar.current
        return walkLogs.contains(where: { log in
            guard let logDate = log.date else { return false }
            return calendar.isDate(logDate, inSameDayAs: date)
        })
    }
}
