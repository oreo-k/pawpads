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

                    let distanceKiloMin = latestDistanceKilo * 0
                    let distanceKiloMax = latestDistanceKilo * 1.2
                    let durationMin = latestDuration * 0
                    let durationMax = latestDuration * 2

                    let durationMinutesMin = latestDurationMinutes*0
                    let durationMinutesMax = latestDurationMinutes*1.2
    

                    // 🐾 散歩距離グラフ
                    VStack(alignment: .leading) {
                        Text("散歩距離推移")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(walkLogs) { log in
                                if log.distance != 0 {
                                    LineMark(
                                        x: .value("日付", log.date ?? Date()),
                                        y: .value("距離 (km)", log.distanceKilo)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.blue)
                                }
                            }
                        }
                        .chartYAxisLabel("距離 (km)", position: .leading)
                        .chartYScale(domain: distanceKiloMin...distanceKiloMax)
                        .frame(height: 250)
                        .padding()
                    }

                    // 🧍‍♂️ 散歩時間グラフ
                    VStack(alignment: .leading) {
                        Text("散歩時間推移")
                            .font(.title3)
                            .bold()
                            .padding(.leading)

                        Chart {
                            ForEach(walkLogs) { log in
                                if log.duration != 0 {
                                    LineMark(
                                        x: .value("日付", log.date ?? Date()),
                                        y: .value("時間 (min)", log.durationMinutes)
                                    )
                                    .symbol(Circle())
                                    .foregroundStyle(Color.green)
                                }
                            }
                        }
                        .chartYAxisLabel("時間 (min)", position: .leading)
                        .chartYScale(domain: durationMinutesMin...durationMinutesMax)
                        .frame(height: 250)
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("散歩量推移グラフ")
        }
    }
}
