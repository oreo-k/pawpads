import SwiftUI
import CoreData

struct WeightLogListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightLog.date, ascending: false)],
        animation: .default
    )
    private var weightLogs: FetchedResults<WeightLog>

    @Environment(\.managedObjectContext) private var viewContext
    @State private var logToDelete: WeightLog?
    @State private var showDeleteConfirmation = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(weightLogs) { log in
                    NavigationLink(destination: WeightLogDetailView(weightLog: log)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateFormatter.string(from: log.date ?? Date()))
                                .font(.headline)
                            Text("Dog: \(String(format: "%.2f", log.weightKg)) kg / \(String(format: "%.2f", log.weightLbs)) lbs")
                            if log.ownerWeightKg != 0 {
                                Text("You: \(String(format: "%.2f", log.ownerWeightKg)) kg")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        logToDelete = weightLogs[index]
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Weight Log History")
            .confirmationDialog("Are you sure you want to delete this weight log?",
                                isPresented: $showDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let log = logToDelete {
                        viewContext.delete(log)
                        try? viewContext.save()
                        logToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    logToDelete = nil
                }
            }
        }
    }
}
