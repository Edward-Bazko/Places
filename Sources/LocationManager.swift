import Foundation
import CoreLocation

typealias LocationManagingResult = Result<CLPlacemark, LocationManagingError>

protocol LocationManaging {
    func requestCurrentPlacemark(using: @escaping (LocationManagingResult) -> ()) throws
}

enum LocationManagingError: Error {
    case currentLocationRequestFailed
    case geocoderFailed
    case userDeniedLocationServiceInSettings
}

final class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    let expirationInterval: TimeInterval = 3
    
    private var pendingCurrentLocationCompletions = [(LocationManagingResult) -> ()]()
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func requestCurrentPlacemark(using completion: @escaping (LocationManagingResult) -> () ) {
        if (isCurrentLocationRequestRequired()) {
            switch CLLocationManager.authorizationStatus() {
            
            case .authorizedAlways, .authorizedWhenInUse:
                pendingCurrentLocationCompletions.append(completion)
                manager.requestLocation()
            
            case .notDetermined:
                pendingCurrentLocationCompletions.append(completion)
                manager.requestWhenInUseAuthorization()
            
            case .restricted, .denied:
                // TODO:
                break
            @unknown default:
                ()
                // TODO:
            }
        }
        else {
            reverseGeocodeCurrentLocation(using: completion)
        }
    }
    
    func isLocationServiceEnabled() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status != .denied && status != .restricted;
    }
    
    private func isCurrentLocationRequestRequired() -> Bool {
        guard let location = manager.location else { return true }
        return Date().timeIntervalSince(location.timestamp) > 2
    }

    private func reverseGeocodeCurrentLocation(using block: @escaping (LocationManagingResult) -> () ) {
        geocoder.reverseGeocodeLocation(manager.location!, completionHandler: { placemarks, error in
            if let placemarks = placemarks {
                let placemark = placemarks.first!
                print("Placemark: \(placemark)")
                block(.success(placemark))
            }
            else if let error = error {
                print("Failure: \(error)")
                block(.failure(.geocoderFailed))
            }
            else {
                fatalError()
            }
        })
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Current location updated: \(locations)")
        reverseGeocodeCurrentLocation { [weak self] result in
            self?.pendingCurrentLocationCompletions.forEach { $0(result) }
            self?.pendingCurrentLocationCompletions.removeAll()
        }
    }

    internal func locationManager(_ manager: CLLocationManager, didFailWithError locationError: Error) {
        print("Current location update failed with error: \(locationError)")
        pendingCurrentLocationCompletions.forEach { $0(.failure(.currentLocationRequestFailed)) }
        pendingCurrentLocationCompletions.removeAll()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if pendingCurrentLocationCompletions.count == 0 { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            pendingCurrentLocationCompletions.forEach{ $0(.failure(.userDeniedLocationServiceInSettings)) }
        case .notDetermined:
            break
        @unknown default:
            ()
            // TODO:
        }
    }
    
    deinit {
        manager.stopUpdatingLocation()
        geocoder.cancelGeocode()
    }
}
