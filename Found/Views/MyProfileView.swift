//
//  MyProfileView.swift
//  Found
//
//  Created by Eno Yoo on 11/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct MyProfileView: View {
    @FirestoreQuery(collectionPath: "items") var items: [Item]
    private var currentUser = Auth.auth().currentUser?.email ?? "unavailable"
    @Environment(\.dismiss) var dismiss
    @State private var pickerIsPresented = false
    @State private var selectedImage = Image(systemName: "person.circle.fill")
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photo = Photo()
    @State private var data = Data()
    @State private var user: User?
    @FirestoreQuery(collectionPath: "users") var photos: [Photo]
    var body: some View {
        NavigationStack() {
            VStack {
                if photos.isEmpty {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(.circle)
                } else {
                    if let profilePicture = photos.first {
                        AsyncImage(url: URL(string: profilePicture.imageURLString)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(.circle)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 150, height: 150)
                        }
                    }
                }
                Text(currentUser.split(separator: "@", maxSplits: 1).first.map(String.init) ?? currentUser)
                    .font(.largeTitle)
                Text(currentUser)
                    .padding(.bottom)
                
                //                HStack {
                //                    Button
                //                }
                
                if let email = Auth.auth().currentUser?.email {
                    let posts = items.filter { $0.userID == email }
                    Text(posts.count == 1 ? "1 Post" : "\(posts.count) Posts")
                        .bold()
                    
                    List(posts) { item in
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
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    ItemViewModel.deleteItem(item: item)
                                }
                                if item.resolved {
                                    Button("Unresolve", systemImage: "tray.and.arrow.up", role: .confirm) {
                                        Task {
                                            await ItemViewModel.unresolveItem(item: item)
                                            
                                        }
                                    }
                                    .tint(item.category == "lost" ? .lostTheme : .foundTheme)
                                } else {
                                    Button("Resolve", systemImage: "tray.and.arrow.down", role: .confirm) {
                                        Task {
                                            await ItemViewModel.resolveItem(item: item)
                                            
                                        }
                                    }
                                    .tint(.resolvedTheme)
                                }
                            }
                        }
                    }
                    .id(items.map { $0.resolved }.description)
                    .listStyle(.sidebar)
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.horizontal)
                    
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Menu", systemImage: "ellipsis") {
                        Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward") {
                            do {
                                try Auth.auth().signOut()
                                print("log out successful")
                                dismiss()
                            } catch {
                                print("Error: could not sign out")
                            }
                        }
                        Button("Edit Profile Picture", systemImage: "square.and.pencil") {
                            pickerIsPresented.toggle()
                        }
                    }
                    .menuStyle(.button)
                }
            }
            .task {
                user = await UserViewModel.getCurrentUser()
                if let email = Auth.auth().currentUser?.email {
                    $photos.path = "users/\(email)/photos"
                }
            }
            .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
            .onChange(of: selectedPhoto) {
                guard let selectedPhoto else {
                    selectedPhoto = nil
                    return
                }
                Task {
                    guard let transferredData = try await selectedPhoto.loadTransferable(type: Data.self) else {
                        print("Error: could not convert data from selectedPhoto")
                        return
                    }
                    guard let user = user else {
                        print("Error: user is nil")
                        return
                    }
                    if let oldPhoto = photos.first {
                        await UserPhotoViewModel.deleteImage(user: user, photo: oldPhoto)
                    }
                    
                    let newPhoto = Photo(userID: currentUser)
                    await UserPhotoViewModel.saveImage(user: user, photo: newPhoto, data: transferredData)
                }
                self.selectedPhoto = nil
                
            }
        }
    }
}

#Preview {
    MyProfileView()
}
