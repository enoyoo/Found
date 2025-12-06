//
//  MapView.swift
//  Found
//
//  Created by Eno Yoo on 11/27/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import MapKit

struct MapView: View {
    
    enum FilterOption: String, Codable, CaseIterable {
        case all, lost, found
        var label: String {
            switch self {
            case .all: return "All"
            case .lost: return "Lost"
            case .found: return "Found"
            }
        }
    }
    
    
    @FirestoreQuery(collectionPath: "items") var items: [Item]
    @State var locationManager = LocationManager()
    @State private var sheetIsPresented = false
    @State private var selectedItem: Item?
    @State private var selectedFilterOption = "all"
    @Environment(\.dismiss) private var dismiss
    
    private var mapCameraPosition: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    var body: some View {
        NavigationStack {
            Map(position: .constant(mapCameraPosition), selection: $selectedItem) {
                UserAnnotation()
                ForEach(filterResults) { item in
                    Marker(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
                        .tag(item)
                        .tint(item.category == "lost" ? .lostTheme : .foundTheme)
                }
            }
            .sheet(item: $selectedItem) { item in
                NavigationStack {
                    DetailView(item: item)
                }
                .presentationDetents([.medium, .large])
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .mapStyle(.standard)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Filter", systemImage: "line.3.horizontal.decrease") {
                        Section("Filter") {
                            Picker("", selection: $selectedFilterOption) {
                                ForEach(FilterOption.allCases, id: \.self) { filterOption in
                                    Text(filterOption.label)
                                        .tag(filterOption.rawValue)
                                }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("New", systemImage: "plus") {
                        sheetIsPresented.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            NavigationStack {
                EditView(item: Item())
                    .navigationTitle("New")
                    .toolbarTitleDisplayMode(.inline)
            }
        }
    }
    var filterResults: [Item] {
        if selectedFilterOption == "all" {
            return items
        } else {
            return items.filter {
                $0.category == selectedFilterOption
            }
        }
    }
    
}

#Preview {
    MapView()
}
