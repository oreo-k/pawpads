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
    span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
    )

    @StateObject private var locationManager = LocationManager()
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            VStack(spacing: 20) {
                Text("ホーム画面")
                    .font(.largeTitle)
                    .padding()

                HStack(spacing: 20) {
                    if !locationManager.isWalking {
                        Button(action: {
                            startWalking()
                        }) {
                            Text("START")
                                .font(.title)
                                .padding()
                                .frame(width: 100, height: 100)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    } else if locationManager.isWalking && !locationManager.isPaused {
                        Button(action: {
                            pauseWalking()
                        }) {
                            Text("PAUSE")
                                .font(.title2)
                                .padding()
                                .frame(width: 100, height: 100)
                                .background(Color.yellow)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    } else if locationManager.isWalking && locationManager.isPaused {
                        Button(action: {
                            resumeWalking()
                        }) {
                            Text("RESUME")
                                .font(.title2)
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
                            .font(.title)
                            .padding()
                            .frame(width: 100, height: 100)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
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
                    }
                    .onReceive(locationManager.$currentLocation) { newLocation in
                        if let newLocation = newLocation {
                            region.center = newLocation
                        }
                    }
                } else {
                    Text("散歩を開始してください")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("ホーム")
            }
            .alert("この散歩を保存しますか？", isPresented: $showSaveAlert) {
                Button("保存しない", role: .cancel) {
                    finishWalking(save: false)
                }
                Button("保存する", role: .none) {
                    finishWalking(save: true)
                }
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



