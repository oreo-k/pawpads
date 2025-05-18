import SwiftUI
import MapKit

struct WalkRouteMapView: View {
    @ObservedObject var locationManager: LocationManager

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.512794, longitude: -122.679565),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: currentPin) 
            { point in
                MapAnnotation(coordinate: point.coordinate) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
        .overlay(
            PolylineOverlay(coordinates: locationManager.walkCoordinates)
        )
        .onReceive(locationManager.$currentLocation) { newLoc in
            if let loc = newLoc {
                region = MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                )
                //print("現在地に中心移動: \(loc.latitude), \(loc.longitude)")//
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
        .padding()
    }
    /*
    private var currentPin: [IdentifiableCoordinate] {
        let loc = locationManager.currentLocation {
            print("ピン表示座標:\(loc.latitude), \(loc.longitude)")
            return [IdentifiableCoordinate(coordinate: loc)]
        }
    }
    */
    private var currentPin: [IdentifiableCoordinate] {
        if let loc = locationManager.currentLocation {
            //print("ピン表示座標:\(loc.latitude), \(loc.longitude)")//
            return [IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(
                latitude:loc.latitude, longitude: loc.longitude))
            ]
        } else {
            return []
        }
    }

}
