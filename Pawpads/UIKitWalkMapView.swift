import SwiftUI
import MapKit

struct UIKitWalkMapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator

        if let loc = mapView.userLocation.location {
            let region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            )
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
    // ✅ 1.既存オーバーレイを削除
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations) // ← これを追加（重複防止）

        // ✅ 2.折れ線の描画
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        // ✅ 3.スタートとゴールのピンを追加
        if coordinates.count >= 2 {
            let startPin = MKPointAnnotation()
            startPin.coordinate = coordinates.first!
            startPin.title = "Start"

            let goalPin = MKPointAnnotation()
            goalPin.coordinate = coordinates.last!
            goalPin.title = "Goal"

            mapView.addAnnotations([startPin, goalPin])
        }

        // 4. 通過点に小さな肉球アノテーションを追加
        for coord in coordinates {
            let paw = MKPointAnnotation()
            paw.coordinate = coord
            paw.title = "step"
            mapView.addAnnotation(paw)
        }

        // ✅ 5.中心位置を更新（最後の位置に合わせる）
        if let last = coordinates.last {
            let region = MKCoordinateRegion(
                center: last,
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }

        // ✅ 現在地を肉球＋30x30＋影で表示
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 1. 現在地カスタマイズ（肉球）
            if annotation is MKUserLocation {
                let identifier = "UserLocation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

                    let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
                    let pawImage = UIImage(systemName: "pawprint.fill", withConfiguration: config)

                    let imageView = UIImageView(image: pawImage)
                    imageView.tintColor = .systemBlue
                    imageView.layer.cornerRadius = 15
                    imageView.clipsToBounds = true
                    imageView.layer.shadowColor = UIColor.black.cgColor
                    imageView.layer.shadowOpacity = 0.25
                    imageView.layer.shadowOffset = CGSize(width: 1, height: 1)
                    imageView.layer.shadowRadius = 2
                    imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

                    view?.addSubview(imageView)
                    view?.frame = imageView.frame
                } else {
                    view?.annotation = annotation
                }

                return view
            }

            // 2. Start / Goal ピン（カラーマーカー）
            if let title = annotation.title ?? "" {
                if title == "Start" || title == "Goal" {
                    let identifier = "StartGoalPin"
                    var pin = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

                    if pin == nil {
                        pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        pin?.canShowCallout = true
                    } else {
                        pin?.annotation = annotation
                    }

                    if title == "Start" {
                        pin?.markerTintColor = .systemGreen
                        pin?.glyphText = "S"
                    } else if title == "Goal" {
                        pin?.markerTintColor = .systemRed
                        pin?.glyphText = "G"
                    }

                    return pin
                }

                // 3. 通過点（小さな肉球）
                if title == "step" {
                    let identifier = "StepDot"
                    var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

                    if view == nil {
                        view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        view?.image = UIImage(systemName: "pawprint.fill")
                        view?.tintColor = .gray
                        view?.frame.size = CGSize(width: 14, height: 14)
                    } else {
                        view?.annotation = annotation
                    }

                    return view
                }
            }

            return nil
        }

    }
}
