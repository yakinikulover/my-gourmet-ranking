import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last
        Task { @MainActor in
            location = latestLocation
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
