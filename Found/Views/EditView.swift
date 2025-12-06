//
//  EditView.swift
//  Found
//
//  Created by Eno Yoo on 11/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct EditView: View {
    @State var item: Item
    @State private var photo = Photo()
    @State private var imageArray: [UIImage] = []
    @State private var dataArray: [Data] = []
    @State private var data = Data()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsPresented = false
    @State private var selectedImage = Image(systemName: "photo")
    @State var locationManager = LocationManager()
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    @FirestoreQuery(collectionPath: "items") var photos: [Photo]
    
    var body: some View {
        NavigationStack {
            Picker("Category", selection: $item.category) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized)
                        .tag(category.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                Section {
                    TextField("Name", text: $item.name)
                        .font(.default)
                    HStack {
                        VStack (alignment: .leading) {
                            if item.itemLocation.isEmpty {
                                Text("Location \(item.category.capitalized)")
                                    .foregroundStyle(.buttonGray)
                            } else {
                                Text(item.itemLocation)
                                    .font(.default)
                                Text(item.itemAddress)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Button("") {
                            sheetIsPresented.toggle()
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("\(item.category.capitalized) on")
                        DatePicker("", selection: $item.time)
                    }
                }
                
                Section {
                    ForEach(photos.enumerated(), id: \.element.id) { index, photo in
                        let url = URL(string: photo.imageURLString)
                        HStack {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .frame(maxWidth: 20)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 20, height: 20)
                            }
                            Text("Photo \(index + 1)")
                        }
                        .swipeActions {
                            Button("", systemImage: "trash", role: .destructive) {
                                Task {
                                    await PhotoViewModel.deleteImage(item: item, photo: photo)
                                }
                            }
                        }
                        
                    }
                    ForEach(imageArray.indices, id: \.self) { index in
                        HStack {
                            
                            Image(uiImage: imageArray[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                .frame(maxWidth: 20)
                            Text("Photo \(index + 1 + photos.count)")
                        }
                        .swipeActions {
                            Button("", systemImage: "trash", role: .destructive) {
                                imageArray.remove(at: index)
                                dataArray.remove(at: index)
                            }
                        }
                    }
                    Button("Add Photo") {
                        pickerIsPresented.toggle()
                    }
                }
                
                Section {
                    TextField("Notes", text: $item.notes, axis: .vertical)
                        .lineLimit(7, reservesSpace: true)
                        .font(.default)
                }
                
                Section {
                    if item.resolved {
                        Button("Unresolve Item", role: .confirm) {
                            Task {
                                await ItemViewModel.unresolveItem(item: item)
                                dismiss()
                            }
                        }
                        .tint(item.category == "lost" ? .lostTheme : .foundTheme)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button("Resolve Item", role: .confirm) {
                            Task {
                                await ItemViewModel.resolveItem(item: item)
                                dismiss()
                            }
                        }
                        .tint(.resolvedTheme)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section {
                    Button("Delete Item", role: .destructive) {
                        ItemViewModel.deleteItem(item: item)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
            }
            .listStyle(.insetGrouped)
            .onAppear {
                item.userID = Auth.auth().currentUser?.email ?? ""
            }
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        Task {
                            let id = await ItemViewModel.saveItem(item: item)
                            if let id = id {
                                item.id = id
                                for data in dataArray {
                                    let photo = Photo(userID: Auth.auth().currentUser?.email ?? "")
                                    await PhotoViewModel.saveImage(item: item, photo: photo, data: data)
                                }
                                dismiss()
                            } else {
                                print("Error: save on detailview did not work")
                            }
                        }
                    }
                    .disabled(item.name.isEmpty)
                }
            }
            .sheet(isPresented: $sheetIsPresented) {
                PlaceLookupView(locationManager: locationManager, item: $item)
            }
            .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
            .onChange(of: selectedPhoto) {
                guard let selectedPhoto else {
                    selectedPhoto = nil
                    return
                }
                Task {
                    if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                       let selectedImage = UIImage(data: data) {
                        imageArray.append(selectedImage)
                        dataArray.append(data)
                    }
                }
                self.selectedPhoto = nil
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditView(item: Item())
    }
}
