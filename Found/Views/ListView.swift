//
//  ListView.swift
//  Found
//
//  Created by Eno Yoo on 12/5/25.
//


//
//  ListView.swift
//  Found
//
//  Created by Eno Yoo on 11/26/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import MapKit

struct ListView: View {
    
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
    enum SortOption: String, Codable, CaseIterable {
        case alphabetical, chronological, asEntered
        var label: String {
            switch self {
            case .alphabetical: return "A-Z"
            case .chronological: return "Date Lost/Found"
            case .asEntered: return "Date Uploaded"
            }
        }
    }
    
    @FirestoreQuery(collectionPath: "items") var items: [Item]
    @State private var sheetIsPresented = false
    @State private var selectedFilterOption = "all"
    @State private var selectedSortOption: SortOption = .alphabetical
    @State private var searchText = ""
    @State private var searchBarIsPresented = false
    @State private var showResolved = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(sortedResults) { item in
                NavigationLink {
                    DetailView(item: item)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.title3)
                            Text(item.itemLocation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            if item.resolved {
                                Text("resolved")
                                    .font(.default)
                                    .bold()
                                    .foregroundStyle(.resolvedTheme)
                            } else {
                                if item.category == "lost" {
                                    Text("lost")
                                        .font(.default)
                                        .bold()
                                        .foregroundStyle(.lostTheme)
                                } else {
                                    Text("found")
                                        .font(.default)
                                        .bold()
                                        .foregroundStyle(.foundTheme)
                                }
                            }
                            Text(item.time.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

            }
            .listStyle(.plain)
            .navigationTitle(selectedFilterOption.capitalized)
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
                        Section {
                            Toggle(isOn: $showResolved) {
                                Text("Show Resolved")
                            }
                        }
                        Section("Sort") {
                            Picker("", selection: $selectedSortOption) {
                                ForEach(SortOption.allCases, id: \.self) { sortOption in
                                    Text(sortOption.label)
                                        .tag(sortOption.rawValue)
                                }
                            }
                        }
                        
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Search", systemImage: "magnifyingglass") {
                        searchBarIsPresented.toggle()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("New", systemImage: "plus") {
                        sheetIsPresented.toggle()
                    }
                }
            }
            .searchable(text: $searchText, isPresented: $searchBarIsPresented, placement: .navigationBarDrawer)
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
    
    var resolvedFilterResults: [Item] {
        if showResolved {
            return filterResults
        } else {
            return filterResults.filter {
                $0.resolved == false
            }
        }
    }
    
    var searchResults: [Item] {
        if searchText.isEmpty {
            return resolvedFilterResults
        } else {
            return resolvedFilterResults.filter {
                $0.name.uppercased().replacingOccurrences(of: " ", with: "").contains(searchText.uppercased().replacingOccurrences(of: " ", with: ""))
            }
        }
    }
    
    var sortedResults: [Item] {
        switch selectedSortOption {
                case .alphabetical:
                    return searchResults.sorted { $0.name < $1.name }
                case .chronological:
                    return searchResults.sorted { $0.time > $1.time }
                case .asEntered:
                    return searchResults.sorted { $0.postedOn > $1.postedOn }
                }
    }
}

#Preview {
    ListView()
}