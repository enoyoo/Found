//
//  ItemViewModel.swift
//  Found
//
//  Created by Eno Yoo on 11/26/25.
//

import Foundation
import FirebaseFirestore

@Observable
class ItemViewModel {
    static func saveItem(item: Item) async -> String? {
        let db = Firestore.firestore()
        if let id = item.id {
            do {
                try db.collection("items").document(id).setData(from: item)
                print("Data uploaded successfully")
                return id
            } catch {
                print("Error: could not update data in 'items' \(error.localizedDescription)")
                return id
            }
        } else {
            do {
                let docRef = try db.collection("items").addDocument(from: item)
                print("Data added successfully")
                return docRef.documentID
            } catch {
                print("could not create a new item in 'items' \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteItem(item: Item) {
        let db = Firestore.firestore()
        guard let id = item.id else {
            print("cannot delete a place with no id")
            return
        }
        Task {
            do {
                try await db.collection("items").document(id).delete()
                print("deleted successfully")
            } catch {
                print("could not delete document id \(id). \(error.localizedDescription)")
            }
        }
    }
    
    static func resolveItem(item: Item) async {
        let db = Firestore.firestore()
        guard let id = item.id else {
            print("item has no id")
            return
        }
        do {
            try await db.collection("items").document(id).updateData([
                "resolved": true
            ])
            print("Item resolved successfully")
        } catch {
            print("Error resolving item: \(error.localizedDescription)")
        }
    }
    
    static func unresolveItem(item: Item) async {
        let db = Firestore.firestore()
        guard let id = item.id else {
            print("item has no id")
            return
        }
        do {
            try await db.collection("items").document(id).updateData([
                "resolved": false
            ])
            print("Item unresolved successfully")
        } catch {
            print("Error unresolving item: \(error.localizedDescription)")
        }
    }
    
}
