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
                    NavigationLink(destination: WalkLogDetailView(walkLog: log)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date: \(log.date ?? Date(), formatter: dateFormatter)")
                                .font(.headline)
                            Text("Distance: \(String(format: "%.2f", log.distance)) m")
                            Text("Duration[s]: \(String(format: "%.0f", log.duration)) 秒")
                            Text("Duration[min]: \(String(format: "%.0f", log.durationMinutes)) min")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Walk History")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
