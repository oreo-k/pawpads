import SwiftUI
import CoreData

struct WalkLogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var walkLog: WalkLog
    @State private var showDeleteAlert = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date: \(walkLog.date ?? Date(), formatter: dateFormatter)")
                .font(.title3)

            Text("Distance: \(String(format: "%.2f", walkLog.distance)) m")
            Text("Duration [s]: \(String(format: "%.0f", walkLog.duration)) 秒")
            Text("Duration [min]: \(String(format: "%.0f", walkLog.durationMinutes)) min")
            
            Spacer()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete This Log", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.red)
            .alert("Are you sure you want to delete this walk log?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteLog()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .padding()
        .navigationTitle("Walk Detail")
    }

    private func deleteLog() {
        viewContext.delete(walkLog)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete log: \(error.localizedDescription)")
        }
    }
}
