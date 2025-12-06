//
//  Place.swift
//  LocationAndPlaceLookup
//
//  Created by Eno Yoo on 11/10/25.
//

import Foundation
import MapKit
import Contacts

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    // initialize a place from just coordinates
    init(location: CLLocation) async {
        // Use the new MKReverseGeocodingRequest
        do {
            let request = MKReverseGeocodingRequest(location: location)
            guard let mapItem = try await request?.mapItems.first else {
                self.init(mapItem: MKMapItem())
                return
            }
            self.init(mapItem: mapItem)
        } catch {
            print("Geocoding Error: \(error.localizedDescription)")
            self.init(mapItem: MKMapItem())
        }
    }

    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var latitude: CLLocationDegrees {
        self.mapItem.location.coordinate.latitude
    }
    
    var longitude: Double {
        self.mapItem.location.coordinate.longitude
    }
    
    
    var address: String {
        // short address
//        print("mapItem.address?.shortAddress: \(mapItem.address?.shortAddress ?? "")")
//        return mapItem.address?.shortAddress ?? ""
        
        // full address
        print("mapItem.address?.fullAddress: \(mapItem.address?.fullAddress ?? "")")
        return mapItem.address?.fullAddress ?? ""
    }

}
