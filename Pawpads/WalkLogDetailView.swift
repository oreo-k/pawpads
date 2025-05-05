import SwiftUI
import CoreData

struct WalkLogDetailView: View {
    let walkLog: WalkLog
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Date: \(dateFormatter.string(from: walkLog.date ?? Date()))")
                .font(.headline)

            Text("Distance: \(String(format: "%.2f", walkLog.distance)) m")
            Text("Duration: \(String(format: "%.0f", walkLog.durationMinutes)) min")
            
            if let feeling = walkLog.feeling, !feeling.isEmpty {
                Text("Feeling: \(feeling)")
                    .italic()
            }

            Button(role: .destructive) {
                deleteLog()
            } label: {
                Label("Delete this walk log", systemImage: "trash")
            }

            Spacer()
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
            print("Failed to delete walk log: \(error)")
        }
    }
}
