import SwiftUI
import CoreData

struct WeightLogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var weightLog: WeightLog

    var body: some View {
        VStack(spacing: 16) {
            Text("Date: \(weightLog.date ?? Date(), formatter: dateFormatter)")
                .font(.headline)

            Text("Dog Weight: \(String(format: "%.1f", weightLog.weightKg)) kg")
            Text("Owner Weight: \(String(format: "%.1f", weightLog.ownerWeightKg)) kg")
            Text("With Dog: \(String(format: "%.1f", weightLog.ownerWithDogWeightKg)) kg")

            Button(role: .destructive) {
                deleteLog()
            } label: {
                Label("Delete This Entry", systemImage: "trash")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Weight Details")
    }

    private func deleteLog() {
        viewContext.delete(weightLog)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete log: \(error.localizedDescription)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
