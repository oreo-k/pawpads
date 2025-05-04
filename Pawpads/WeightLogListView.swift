import SwiftUI
import CoreData

struct WeightLogListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightLog.date, ascending: false)],
        animation: .default
    )
    private var weightLogs: FetchedResults<WeightLog>

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(weightLogs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: log.date ?? Date()))
                            .font(.headline)
                        VStack(alignment: .leading) {
                            Text("Your Pal: \(String(format: "%.2f", log.weightKg)) kg / \(String(format: "%.2f", log.weightLbs)) lbs")
                                .font(.subheadline)
                            if log.ownerWeightKg != 0 && log.ownerWeightLbs != 0 {
                                Text("You: \(String(format: "%.2f", log.ownerWeightKg)) kg / \(String(format: "%.2f", log.ownerWeightLbs)) lbs")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Weight Log History")
        }
    }
}

