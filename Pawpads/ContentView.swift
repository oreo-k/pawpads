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
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // 初期値（例: Portland）
    span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
    )

    @StateObject private var locationManager = LocationManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var walkMapView: UIKitWalkMapView

    init() {
        let manager = LocationManager()
        _locationManager = StateObject(wrappedValue: manager)
        _walkMapView = State(initialValue: UIKitWalkMapView(locationManager: manager))
    }
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
                        WalkStampGrid()
                            .padding(.horizontal)
                        Text("Shall We Walking??")
                            .font(.largeTitle)
                            .padding()
                        Button(action: {
                            startWalking()
                        }) {
                            Image(systemName:"play")
                                .font(.system(size: 30, weight: .bold))
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
                        Text(locationManager.isPaused ? "Paused..." : "Walking...")
                            .font(.title2)
                            .foregroundColor(locationManager.isPaused ? .gray : .green)

                        Text("Duration: \(formatElapsedTime()) sec")
                            .font(.title3)

                        Text("Distance: \(String(format: "%.2f", locationManager.distance)) m")
                            .font(.title3)

                        WalkMapViewRepresentable(locationManager: locationManager, mapView: walkMapView)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding()

                        HStack(spacing: 20) {
                            if !locationManager.isPaused {
                                Button(action: pauseWalking) {
                                    Image(systemName:"pause")
                                        .font(.system(size:30, weight: .bold))
                                        .padding()
                                        .frame(width: 100, height: 100)
                                        .background(Color.yellow)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            } else {
                                Button(action: resumeWalking) {
                                    Image(systemName:"play")
                                        .font(.system(size: 30, weight: .bold))
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
                                Image(systemName:"stop")
                                    .font(.system(size: 30, weight: .bold))
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
                    Text("HOME")
                }

            WalkMainView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("Walking Record")
                }

            WeightMainView()
                .tabItem {
                    Image(systemName: "scalemass")
                    Text("Weight")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Setting")
                }

            DebugTestMapView()
                .tabItem {
                    Image(systemName: "location.circle")
                    Text("Test Map")
    }
        }
        .alert("Do you want to save?", isPresented: $showSaveAlert) {
            Button("Discard", role: .cancel) {
                finishWalking(save: false)
            }
            Button("Save", role: .none) {
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
        walkMapView.stopWalk()
        timer = nil

        if save {
            saveWalkLog()
        }
        locationManager.distance=0
        locationManager.walkCoordinates.removeAll()
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
            print("Completed to Save")
        } catch {
            print("Failed to Save: \(error.localizedDescription)")
        }
    }

    // 経過秒数を計算するヘルパー
    private func calculateElapsedSeconds() -> Int64 {
        guard let start = startTime else { return 0 }
        let totalSeconds = Int64(now.timeIntervalSince(start) - pausedTimeTotal)
        return totalSeconds
    }

}



