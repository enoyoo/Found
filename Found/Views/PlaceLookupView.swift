//
//  PlaceLookupView.swift
//  Snacktacular
//
//  Created by Eno Yoo on 11/24/25.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    
    let locationManager: LocationManager
    @Binding var spot: Spot
    @State var placeVM = PlaceViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "mappin.slash")
                } else {
                    List(placeVM.places) { place in
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.title2)
                            Text(place.address)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            spot.name = place.name
                            spot.address = place.address
                            spot.latitude = place.latitude
                            spot.longitude = place.longitude
                            dismiss()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Location Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .autocorrectionDisabled()
        .onAppear {
            searchRegion = locationManager.getRegionAroundCurrentLocation() ?? MKCoordinateRegion()
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchText) { oldValue, newValue in
            searchTask?.cancel()
            guard !newValue.isEmpty else {
                placeVM.places.removeAll()
                return
            }
            searchTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                    if Task.isCancelled { return }
                    if searchText == newValue {
                        try await placeVM.search(text: newValue, region: searchRegion)
                    }
                } catch {
                    if !Task.isCancelled {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceLookupView(locationManager: LocationManager(), spot: .constant(Spot()))
}
