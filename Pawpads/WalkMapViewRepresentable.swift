import SwiftUI

struct WalkMapViewRepresentable: UIViewRepresentable {
    let locationManager: LocationManager
    let mapView: UIKitWalkMapView

    func makeUIView(context: Context) -> UIKitWalkMapView {
        return mapView
    }

    func updateUIView(_ uiView: UIKitWalkMapView, context: Context) {}
}
