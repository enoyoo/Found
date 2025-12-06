//
//  DetailView.swift
//  Found
//
//  Created by Eno Yoo on 11/26/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MapKit
struct DetailView: View {
    @State var item: Item
    @State private var sheetIsPresented = false
    @State var locationManager = LocationManager()
    
    private var mapCameraPosition: MapCameraPosition {
        let coordinate = CLLocationCoordinate2D(
            latitude: item.latitude,
            longitude: item.longitude
        )
        return .region(
            MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
        )
    }
    
    @FirestoreQuery(collectionPath: "items") var photos: [Photo]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            NavigationStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.largeTitle)
                                .bold()
                            //                            .foregroundStyle(category == "lost" ? .lostTheme : .foundTheme)
                            Text(item.itemLocation)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(item.category == "lost" ? .lostTheme : .foundTheme)
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            if item.userID == Auth.auth().currentUser?.email {
                                MyProfileView()
                            } else {
                                ProfileView(item: item)
                            }
                        } label: {
                            VStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(item.userID.split(separator: "@", maxSplits: 1).first.map(String.init) ?? item.userID)
                            }
                            .tint(.accentColor)
                        }
                        
                        
                    }
                    .padding(.bottom)
                    
                    if photos.isEmpty {
                        Text("No Photos Available")
                            .foregroundStyle(.secondary)
                            .frame(height: 200)
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(photos) { photo in
                                    let url = URL(string: photo.imageURLString)
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 200, height: 200)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    if !item.notes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Notes: ")
                            Text(item.notes)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Address: ")
                        Text(item.itemAddress)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom)
                    
                    Map(position: .constant(mapCameraPosition)) {
                        Marker(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
                            .tint(item.category == "lost" ? .lostTheme : .foundTheme)
                        UserAnnotation()
                    }
                    .mapControls {
                        MapCompass()
                    }
                    .mapStyle(.standard)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    Spacer()
                    
                    
                }
                .padding()
                .navigationTitle("\(item.category.capitalized) Item")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if item.id != nil {
                        guard let id = item.id else {
                            print("has no id")
                            return
                        }
                        $photos.path = "items/\(id)/photos"
                    }
                }
                .toolbar {
                    if item.userID == Auth.auth().currentUser?.email {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Edit", systemImage: "square.and.pencil") {
                                sheetIsPresented.toggle()
                            }
                            .disabled(item.userID != Auth.auth().currentUser?.email)
                        }
                        ToolbarItem(placement: .destructiveAction) {
                            Button("Delete Item", systemImage: "trash.fill",  role: .destructive) {
                                ItemViewModel.deleteItem(item: item)
                                dismiss()
                            }
                            .tint(.red)
                        }
                    }
                    
                }
            }
            .sheet(isPresented: $sheetIsPresented) {
                NavigationStack {
                    EditView(item: item)
                        .navigationTitle("Edit Item")
                        .toolbarTitleDisplayMode(.inline)
                }
                .onDisappear {
                    Task {
                        await reloadItem()
                    }
                }
            }
        }
    }
    
    func reloadItem() async {
        guard let itemID = item.id else { return }
        
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("items").document(itemID).getDocument()
            if let updatedItem = try? document.data(as: Item.self) {
                item = updatedItem
            }
        } catch {
            print("Error reloading item: \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    NavigationStack {
        DetailView(item: Item.preview)
    }
}
