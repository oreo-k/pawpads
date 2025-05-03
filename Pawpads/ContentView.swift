import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var startTime: Date? = nil
    @State private var pauseStartTime: Date? = nil
    @State private var pausedTimeTotal: TimeInterval = 0
    @State private var now: Date = Date()
    @State private var timer: Timer? = nil
    @State private var showSaveAlert = false
    @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // 初期値（例: サンフランシスコ）
    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )

    @StateObject private var locationManager = LocationManager()
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WalkLog.date, ascending: true)],
        animation: .default
    )
    private var walkLogs: FetchedResults<WalkLog>

    var body: some View {
        TabView {
            VStack {
                if !locationManager.isWalking {
                    VStack{
                        WalkStampGridView()
                            .padding(.horizontal)
                        Text("お散歩を開始しましょう！")
                            .font(.largeTitle)
                            .padding()
                        Button(action: {
                            startWalking()
                        }) {
                            Text("START")
                                .font(.system(size: 28, weight: .bold))
                                .padding()
                                .frame(width: 100, height: 100)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }

                if locationManager.isWalking {
                    VStack(spacing: 10) {
                        Text(locationManager.isPaused ? "一時停止中です" : "散歩中です！")
                            .font(.title2)
                            .foregroundColor(locationManager.isPaused ? .gray : .green)

                        Text("経過時間: \(formatElapsedTime())")
                            .font(.title3)

                        Text("移動距離: \(String(format: "%.2f", locationManager.distance)) m")
                            .font(.title3)

                        CurrentLocationMapView(locationManager: locationManager)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding()

                        HStack(spacing: 20) {
                            if !locationManager.isPaused {
                                Button(action: pauseWalking) {
                                    Text("PAUSE")
                                        .font(.system(size: 22, weight: .bold))
                                        .padding()
                                        .frame(width: 100, height: 100)
                                        .background(Color.yellow)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            } else {
                                Button(action: resumeWalking) {
                                    Text("RESUME")
                                        .font(.system(size: 22, weight: .bold))
                                        .padding()
                                        .frame(width: 100, height: 100)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }

                            Button(action: {
                                showSaveAlert = true
                            }) {
                                Text("FINISH")
                                    .font(.system(size: 22, weight: .bold))
                                    .padding()
                                    .frame(width: 100, height: 100)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .onReceive(locationManager.$currentLocation) { newLoc in
                        if let loc = newLoc {
                            region.center = loc
                        }
                    }
                }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }

            WalkMainView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("散歩記録")
                }

            WeightMainView()
                .tabItem {
                    Image(systemName: "scalemass")
                    Text("体重")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .alert("この散歩を保存しますか？", isPresented: $showSaveAlert) {
            Button("保存しない", role: .cancel) {
                finishWalking(save: false)
            }
            Button("保存する", role: .none) {
                finishWalking(save: true)
            }
        }
    }


    private func startWalking() {
        locationManager.isWalking = true
        locationManager.isPaused = false
        startTime = Date()
        pausedTimeTotal = 0
        now = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            now = Date()
        }
    }

    private func pauseWalking() {
        locationManager.isPaused = true
        pauseStartTime = Date()
        timer?.invalidate()
    }

    private func resumeWalking() {
        if let pauseStart = pauseStartTime {
            pausedTimeTotal += Date().timeIntervalSince(pauseStart)
        }
        locationManager.isPaused = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            now = Date()
        }
    }

    private func finishWalking(save:Bool) {
        locationManager.isWalking = false
        locationManager.isPaused = false
        timer?.invalidate()
        timer = nil

        if save {
            saveWalkLog()
        }
        locationManager.distance=0
    }

    private func formatElapsedTime() -> String {
        guard let start = startTime else { return "00:00:00" }
        let elapsed = Int(now.timeIntervalSince(start) - pausedTimeTotal)

        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func saveWalkLog() {
        let newLog = WalkLog(context: viewContext)
        newLog.date = Date()
        newLog.duration = calculateElapsedSeconds()
        newLog.distance = locationManager.distance
        newLog.distanceKilo = newLog.distance/1000
        newLog.feeling = "" // ← 今は空欄（あとで気分入力を付けてもOK）
        newLog.durationMinutes = Double(newLog.duration) / 60.0
        
        do {
            try viewContext.save()
            print("散歩ログ保存完了！")
        } catch {
            print("保存失敗: \(error.localizedDescription)")
        }
    }

    // 経過秒数を計算するヘルパー
    private func calculateElapsedSeconds() -> Int64 {
        guard let start = startTime else { return 0 }
        let totalSeconds = Int64(now.timeIntervalSince(start) - pausedTimeTotal)
        return totalSeconds
    }

}



