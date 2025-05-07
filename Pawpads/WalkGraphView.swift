import SwiftUI
import Charts
import CoreData

struct WalkGraphView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: true)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    let latestDistanceKilo = walkLogs.last?.distanceKilo ?? 1
                    let latestDuration = walkLogs.last?.duration ?? 600
                    let latestDurationMinutes = walkLogs.last?.durationMinutes ?? 15

                    let distanceKiloMin = walkLogs.map{ $0.distanceKilo}.min() ?? 0
                    let distanceKiloMax = walkLogs.map{ $0.distanceKilo}.max() ?? 0

                    let durationMin = walkLogs.map { $0.duration }.min() ?? 0
                    let durationMax = walkLogs.map { $0.duration }.max() ?? 0
                    
                    let durationMinutesMin = walkLogs.map { $0.durationMinutes }.min() ?? 0
                    let durationMinutesMax = walkLogs.map { $0.durationMinutes }.max() ?? 0


                    // 🐾 散歩距離グラフ
                    VStack(alignment: .leading) {
                        Text("Trend Walking Distance")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(walkLogs) { log in
                                if log.distance != 0 {
                                    LineMark(
                                        x: .value("Date", log.date ?? Date()),
                                        y: .value("Distance (km)", log.distanceKilo)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.blue)
                                }
                            }
                        }
                        .chartYAxisLabel("Distance (km)", position: .leading)
                        .chartYScale(domain: distanceKiloMin...distanceKiloMax)
                        .frame(height: 250)
                        .padding()
                    }

                    // 🧍‍♂️ 散歩時間グラフ
                    VStack(alignment: .leading) {
                        Text("Trend Walking Time")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(walkLogs) { log in
                                if log.duration != 0 {
                                    LineMark(
                                        x: .value("Date", log.date ?? Date()),
                                        y: .value("Time (min)", log.durationMinutes)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.green)
                                }
                            }
                        }
                        .chartYAxisLabel("Time (min)", position: .leading)
                        .chartYScale(domain: durationMinutesMin...durationMinutesMax)
                        .frame(height: 250)
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Walking Trend Chart")
        }
    }
}
