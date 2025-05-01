import SwiftUI
import MapKit

struct CurrentLocationMapView: View {
    @ObservedObject var locationManager: LocationManager

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.0, longitude: 135.0), // 仮の初期値
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: currentLocationWrapped) { point in
            MapAnnotation(coordinate: point.coordinate) {
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.blue)
                    .font(.title)
            }
        }
        .onReceive(locationManager.$currentLocation) { newLoc in
            if let loc = newLoc {
                region.center = loc
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
    }

    // 現在地を Identifiable な構造体にラップ
    var currentLocationWrapped: [LocationPoint] {
        if let loc = locationManager.currentLocation {
            return [LocationPoint(coordinate: loc)]
        } else {
            return []
        }
    }
}

// ラップ用構造体
struct LocationPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
