import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    // 現在位置（UIやMap表示に使う）
    @Published var currentLocation: CLLocationCoordinate2D?

    // 累積歩行距離（m）
    @Published var distance: CLLocationDistance = 0.0

    // 通過した座標（ルート描画などに使用可能）
    @Published var walkCoordinates: [CLLocationCoordinate2D] = []

    // 歩行状態
    var isWalking = false
    var isPaused = false

    // 内部的に最後に記録された座標（距離計算用）
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
        }

        // 🐾 距離・ルート処理
        if isWalking && !isPaused {
            if let last = lastLocation {
                let delta = location.distance(from: last)
                if delta > 1.0 { // 小さな揺れを除外（1m以上のみ記録）
                    DispatchQueue.main.async {
                        self.distance += delta
                        self.walkCoordinates.append(location.coordinate)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.walkCoordinates.append(location.coordinate)
                }
            }
            lastLocation = location
        }
    }

    // MARK: - 公開メソッド（UIから操作）

    func startWalk() {
        isWalking = true
        isPaused = false
        distance = 0.0
        walkCoordinates = []
        lastLocation = nil
    }

    func togglePause() {
        isPaused.toggle()
    }

    func stopWalk() {
        isWalking = false
        isPaused = false
        lastLocation = nil
    }
}
