
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
  var locationManager = CLLocationManager()
  @Published var authorized = false

  override init() {
    super.init()
    locationManager.delegate = self
    if locationManager.authorizationStatus == .authorizedWhenInUse {
      authorized = true
      locationManager.startMonitoringSignificantLocationChanges()
    }
  }

  func requestAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if locationManager.authorizationStatus == .authorizedWhenInUse ||
      locationManager.authorizationStatus == .authorizedAlways {
      authorized = true
    } else {
      authorized = false
    }
  }
}
