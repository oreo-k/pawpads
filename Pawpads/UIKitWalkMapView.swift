import UIKit
import MapKit
import CoreLocation
import Combine

enum AnnotationType: String {
    case start = "Start"
    case goal = "Goal"
    case paw = "paw"

    var symbolName: String {
        switch self {
        case .start: return "flag.circle"
        case .goal: return "checkered.flag"
        case .paw: return "pawprint.fill"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .start: return .systemGreen
        case .goal: return .systemRed
        case .paw: return .systemPink
        }
    }

    var symbolSize: CGFloat {
        switch self {
        case .start: return 20
        case .goal: return 20
        case .paw: return 14 // 肉球だけ小さめに
        }
    }

    var symbolWeight: UIImage.SymbolWeight {
        switch self {
        case .start: return .semibold
        case .goal: return .semibold
        case .paw: return .regular
        }
    }
}


class UIKitWalkMapView: UIView, MKMapViewDelegate {
    private let mapView = MKMapView()
    private var cancellables = Set<AnyCancellable>()

    private var lastPawprintCoordinate: CLLocation?
    private var hasCenteredOnUser = false
    private var startCoordinate: CLLocationCoordinate2D?
    private var currentUserLocation: CLLocation?

    init(locationManager: LocationManager) {
        super.init(frame: .zero)
        setupMapView()
        bindToLocationManager(locationManager)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    private func bindToLocationManager(_ locationManager: LocationManager) {
        locationManager.$currentLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.handleLocationUpdate(coordinate)
            }
            .store(in: &cancellables)
    }

    private func handleLocationUpdate(_ coordinate: CLLocationCoordinate2D) {
        let current = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        currentUserLocation = current

        if !hasCenteredOnUser {
            hasCenteredOnUser = true
            let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }

        if startCoordinate == nil {
            startCoordinate = coordinate
            addAnnotation(at: coordinate, title: "Start")
            lastPawprintCoordinate = current
            return
        }

        /*
        // 現在地と肉球の位置が近すぎる場合は追加しない（例：半径5m以内）
        if let userLocation = currentUserLocation {
            let distanceToUser = current.distance(from: userLocation)
            if distanceToUser < 5 {
                return
            }
        }
        */

        if let last = lastPawprintCoordinate {
            let distance = current.distance(from: last)
            if distance >= 10 {
                addAnnotation(at: coordinate, title: "paw")
                lastPawprintCoordinate = current
            }
        } else {
            addAnnotation(at: coordinate, title: "paw")
            lastPawprintCoordinate = current
        }
    }

    func stopWalk() {
        if let last = lastPawprintCoordinate?.coordinate {
            addAnnotation(at: last, title: "Goal")
        }

        // "Start", "paw", "Goal" などのアノテーションを削除（現在地以外）
        let annotationsToRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotationsToRemove)

        lastPawprintCoordinate = nil
        startCoordinate = nil
    }

    private func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "customAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }

        if let title = annotation.title ?? "",
        let type = AnnotationType(rawValue: title) {

            // 1. Symbolのサイズ＋太さ設定
            let config = UIImage.SymbolConfiguration(pointSize: type.symbolSize,
                                                    weight: type.symbolWeight)

            // 2. シンボル画像を生成
            if let baseImage = UIImage(systemName: type.symbolName, withConfiguration: config) {

                // 3. 色を“焼き付けた”画像を生成して設定（これで黒くならない！）
                let coloredImage = baseImage
                    .withTintColor(type.tintColor, renderingMode: .alwaysOriginal)

                annotationView?.image = coloredImage
            }
        }
        return annotationView
    }
}
