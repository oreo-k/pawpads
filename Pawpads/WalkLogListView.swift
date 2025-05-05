import SwiftUI
import CoreData

struct WalkLogListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: false)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    @Environment(\.managedObjectContext) private var viewContext
    @State private var logToDelete: WalkLog? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(walkLogs) { log in
                    NavigationLink(destination: WalkLogDetailView(walkLog: log)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date: \(log.date ?? Date(), formatter: dateFormatter)")
                                .font(.headline)
                            Text("Distance: \(String(format: "%.2f", log.distance)) m")
                            Text("Duration [s]: \(String(format: "%.0f", log.duration)) 秒")
                            Text("Duration [min]: \(String(format: "%.0f", log.durationMinutes)) min")
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            logToDelete = log
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Walk History")
            .alert("Are you sure you want to delete this walk log?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let log = logToDelete {
                        deleteLog(log)
                    }
                    logToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    logToDelete = nil
                }
            }
        }
    }

    private func deleteLog(_ log: WalkLog) {
        viewContext.delete(log)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete log: \(error.localizedDescription)")
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
