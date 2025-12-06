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
    @Binding var item: Item
    @State var placeVM = PlaceViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "mappin.slash")
                } else {
                    List(placeVM.places) { place in
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .opacity(0.5)
                            VStack(alignment: .leading) {
                                Text(place.name)
                                    .font(.default)
                                    .bold()
                                Text(place.address)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onTapGesture {
                            item.itemLocation = place.name
                            item.itemAddress = place.address
                            item.latitude = place.latitude
                            item.longitude = place.longitude
                            dismiss()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer)
        .focused($textFieldIsFocused)
        .autocorrectionDisabled()
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(10))
                textFieldIsFocused = true
            }
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
    PlaceLookupView(locationManager: LocationManager(), item: .constant(Item()))
}
