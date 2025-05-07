import SwiftUI
import MapKit

struct WalkRouteMapView: View {
    @ObservedObject var locationManager: LocationManager

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: currentPin) 
            { point in
                MapAnnotation(coordinate: point.coordinate) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .background(Color.white)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
        .overlay(
            PolylineOverlay(coordinates: locationManager.walkCoordinates)
        )
        .onReceive(locationManager.$currentLocation) { newLoc in
            if let loc = newLoc {
                region.center = loc
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
        .padding()
    }
    private var currentPin: [IdentifiableCoordinate] {
        if let loc = locationManager.currentLocation {
            print("ピン表示座標:\(loc.latitude), \(loc.longitude)")
            return [IdentifiableCoordinate(coordinate: loc)]
        } else {
            return []
        }
    }

}
