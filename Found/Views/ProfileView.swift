//
//  ProfileView.swift
//  Found
//
//  Created by Eno Yoo on 11/28/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State var item: Item
    @State private var user: User?
    @State private var isLoading = true
    @State private var isLoadingConversation = false
    @State private var sheetIsPresented = false
    @State private var conversationID = ""
    @FirestoreQuery(collectionPath: "items") var items: [Item]
    @FirestoreQuery(collectionPath: "users") var photos: [Photo]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack() {
            if isLoading {
                ProgressView()
            } else if let user = user {
                VStack {
                    if photos.isEmpty {
                        Image(systemName: "person.crop.circle.fill")
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
                    
                    Text(user.username.isEmpty ? item.userID.split(separator: "@", maxSplits: 1).first.map(String.init) ?? item.userID : user.username)
                        .font(.largeTitle)
                    Text(user.email)
                        .padding(.bottom)
                    
                    Button {
                        Task {
                            if let convID = await MessagesViewModel.getConversation(otherUserID: item.userID) {
                                conversationID = convID
                                isLoadingConversation = false
                                sheetIsPresented = true
                            } else {
                                isLoadingConversation = false
                                print("Error: could not get/create conversation")
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Send Message")
                        }
                        .padding(5)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.bottom)
                    
                    let posts = items.filter { $0.userID == item.userID }
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
                        }
                    }
                    .listStyle(.sidebar)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView(
                    "User Not Found",
                    systemImage: "person.slash",
                    description: Text("This user's profile could not be loaded")
                )
            }
        }
        .task {
            isLoading = true
            
            user = await UserViewModel.getUser(byEmail: item.userID)
            
            $photos.path = "users/\(item.userID)/photos"
            
            isLoading = false
        }
        .sheet(isPresented: $sheetIsPresented) {
            if !conversationID.isEmpty {
                NavigationStack {
                    ChatView(conversationID: conversationID, otherUserID: item.userID)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(item: Item.preview)
    }
}
