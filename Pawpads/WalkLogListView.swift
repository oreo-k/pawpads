import SwiftUI
import CoreData

struct WalkLogListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: false)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    var body: some View {
        NavigationView {
            List {
                ForEach(walkLogs) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("日付: \(log.date ?? Date(), formatter: dateFormatter)")
                            .font(.headline)
                        Text("距離: \(String(format: "%.2f", log.distance)) m")
                        Text("時間: \(String(format: "%.0f", log.duration)) 秒")
                        Text("時間: \(String(format: "%.0f", log.durationMinutes)) min")
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("散歩履歴一覧")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
