import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update location when user moves 100 meters
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle denied permission
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func calculateDistance(to providerLocation: CLLocation?) -> Double? {
        guard let currentLocation = currentLocation,
              let providerLocation = providerLocation else {
            return nil
        }
        
        return currentLocation.distance(from: providerLocation) / 1000 // Convert to kilometers
    }
    
    func formatDistance(_ distance: Double) -> String {
        if distance < 1 {
            return "\(Int(distance * 1000))m away"
        } else {
            return String(format: "%.1fkm away", distance)
        }
    }
    
    func getNearbyProviders(_ providers: [Provider], within radius: Double = 50) -> [Provider] {
        guard let currentLocation = currentLocation else {
            return providers
        }

        return providers.filter { provider in
            guard let providerLocation = provider.location else {
                return false
            }
            let providerCLLocation = CLLocation(latitude: providerLocation.latitude, longitude: providerLocation.longitude)
            let distance = currentLocation.distance(from: providerCLLocation) / 1000
            return distance <= radius
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
            case .denied, .restricted:
                self.stopLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
} 