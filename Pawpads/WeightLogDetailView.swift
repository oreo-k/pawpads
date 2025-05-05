import SwiftUI
import CoreData

struct WeightLogDetailView: View {
    var weightLog: WeightLog
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date: \(dateFormatter.string(from: weightLog.date ?? Date()))")
                .font(.title3)
            
            Text("Dog: \(String(format: "%.2f", weightLog.weightKg)) kg / \(String(format: "%.2f", weightLog.weightLbs)) lbs")
            
            if weightLog.ownerWeightKg != 0 {
                Text("You: \(String(format: "%.2f", weightLog.ownerWeightKg)) kg")
            }

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
            .alert("Are you sure you want to delete this weight log?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteLog()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .padding()
        .navigationTitle("Weight Detail")
    }

    private func deleteLog() {
        viewContext.delete(weightLog)
        try? viewContext.save()
        dismiss()
    }
}
