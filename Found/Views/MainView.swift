//
//  MainView.swift
//  Found
//
//  Created by Eno Yoo on 11/27/25.
//

import SwiftUI
import FirebaseFirestore

struct MainView: View {
    @FirestoreQuery(collectionPath: "items") var items: [Item]
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        TabView {
            ListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            MessagesListView()
                .tabItem {
                    Label("Messages", systemImage: "bubble")
                }
            
            MyProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainView()
}
