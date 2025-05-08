import SwiftUI
import MapKit

/*
struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
*/
struct DebugTestMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.512794, longitude: -122.679565), // Portland
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: testPin) { point in
            MapAnnotation(coordinate: point.coordinate) {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.blue)
                    .frame(width: 25, height: 25)
                    //.background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
        .padding()
    }

    var testPin: [IdentifiableCoordinate] {
        [IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 45.512794, longitude: -122.679565))]
    }
}
