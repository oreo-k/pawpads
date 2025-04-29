//
//  LocationManager.swift
//  Pawpads
//
//  Created by REO KOSAKA on 4/26/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isWalking: Bool = false
    @Published var isPaused: Bool = false
    
    @Published var distance: Double = 0.0 // 総移動距離（メートル）
    @Published var currentLocation: CLLocationCoordinate2D?

    private var locationManager: CLLocationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if isWalking && !isPaused {
            if let last = lastLocation {
                let delta = location.distance(from: last) // 直前地点との距離（メートル）
                if delta > 1.0 { // 小さい揺れは無視（1m以上動いたら加算）
                    distance += delta
                }
            }
            lastLocation = location
        }
        currentLocation = location.coordinate
    }
}
