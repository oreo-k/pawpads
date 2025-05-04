import SwiftUI
import Charts
import CoreData

struct WeightGraphView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeightLog.date, ascending: true)],
        animation: .default
    )
    private var weightLogs: FetchedResults<WeightLog>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    let latestDogWeight = weightLogs.last?.weightKg ?? 10.0
                    let latestOwnerWeight = weightLogs.last?.ownerWeightKg ?? 60.0

                    let dogMin = latestDogWeight * 0.8
                    let dogMax = latestDogWeight * 1.2
                    let ownerMin = latestOwnerWeight * 0.8
                    let ownerMax = latestOwnerWeight * 1.2

                    // 🐾 愛犬体重グラフ
                    VStack(alignment: .leading) {
                        Text("Trend Your Dog's Weight")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(weightLogs) { log in
                                if log.weightKg != 0 {
                                    LineMark(
                                        x: .value("Date", log.date ?? Date()),
                                        y: .value("Weight (kg)", log.weightKg)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.blue)
                                }
                            }
                        }
                        .chartYAxisLabel("Weight (kg)", position: .leading)
                        .chartYScale(domain: dogMin...dogMax) // ← ここ追加
                        .frame(height: 250)
                        .padding()
                    }

                    // 🧍‍♂️ 飼い主体重グラフ
                    VStack(alignment: .leading) {
                        Text("Trend Your Weight")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(weightLogs) { log in
                                if log.ownerWeightKg != 0 {
                                    LineMark(
                                        x: .value("Date", log.date ?? Date()),
                                        y: .value("Weight (kg)", log.ownerWeightKg)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.green)
                                }
                            }
                        }
                        .chartYAxisLabel("Weight (kg)", position: .leading)
                        .chartYScale(domain: ownerMin...ownerMax) // ← ここ追加
                        .frame(height: 250)
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Trend Weight")
        }
    }
}

