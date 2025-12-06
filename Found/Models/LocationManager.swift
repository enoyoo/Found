//
//  LocationManager.swift
//  LocationAndPlaceLookup
//
//  Created by Eno Yoo on 11/10/25.
//

import Foundation
import MapKit
import SwiftUI

@Observable

class LocationManager: NSObject, CLLocationManagerDelegate {
    // !!!: Always add info.plist message for Privacy - Location When in Use Usage Description
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var locationUpdated: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // get a region around current location with specified radius in meters
    func getRegionAroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else { return nil }
        
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
    }
}

// delegate methods that apple has created and will call, but that we filled out
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {return}
        location = newLocation
        //call the callback function to indicate we've updated a location
        locationUpdated?(newLocation)
        
        // you can uncomment the line below when you only want to get the location once, not repeatedly
         manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManger authorization granted")
        case .denied, .restricted:
            print("LocationManger authorization denied")
            errorMessage = "LocationManger authorization denied"
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("LocationManger authorization not determined")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("LocationManager Error: \(errorMessage ?? "n/a")")
    }
}

