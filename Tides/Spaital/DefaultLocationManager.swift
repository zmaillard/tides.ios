//
//  LocationManager.swift
//  tides
//
//  Created by Zach Maillard on 9/25/26.
//
import CoreLocation

class DefaultLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {
    
    var locationDataManager: CLLocationManager
    private let requestLocation: () -> Void
    private let requestAuthorization: () -> Void
    
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    var authorizationStatus: CLAuthorizationStatus?
    
    init(
        requestLocation: (() -> Void)? = nil,
        requestAuthorization: (() -> Void)? = nil
    ) {
        let locationDataManager = CLLocationManager()
        self.locationDataManager = locationDataManager
        self.requestLocation = requestLocation ?? { locationDataManager.requestLocation() }
        self.requestAuthorization = requestAuthorization ?? { locationDataManager.requestWhenInUseAuthorization() }
        super.init()
        locationDataManager.delegate = self
    }
    
    var currentLocation: CLLocation {
        get async throws {
            if self.continuation != nil {
                self.continuation?.resume(throwing: LocationManagerError.replaceContinuation)
                self.continuation = nil
            }
            
            return try await withCheckedThrowingContinuation {
                continuation in
                
                self.continuation = continuation
                requestLocation()
            }
        }
    }
    
    enum LocationManagerError: String, Error, Equatable {
        case replaceContinuation = "Continuation replaced"
        case locationNotFound = "No location found"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            continuation?.resume(returning: location)
            continuation = nil
        } else {
            continuation?.resume(throwing: LocationManagerError.locationNotFound)
            continuation = nil
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus(manager.authorizationStatus)
    }

    func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            requestLocation()
        case .restricted:
            authorizationStatus = .restricted
        case .denied:
            authorizationStatus = .notDetermined
            requestAuthorization()
        default:
            break
        }
        
    }
}
