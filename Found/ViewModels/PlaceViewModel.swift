//
//  PlaceViewModel.swift
//  LocationAndPlaceLookup
//
//  Created by Eno Yoo on 11/10/25.
//

import Foundation
import MapKit

@MainActor
@Observable
class PlaceViewModel {
    var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) async throws {
        // create a search request
        let searchRequest = MKLocalSearch.Request()
        // pass in search text to request
        searchRequest.naturalLanguageQuery = text
        // establish search region
        searchRequest.region = region
        // create search object that performs search
        let search = MKLocalSearch(request: searchRequest)
        // run search
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Location Found"])
        }
        self.places = response.mapItems.map(Place.init)
        
        
    }
}
