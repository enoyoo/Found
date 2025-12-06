//
//  PhotoViewModel.swift
//  Found
//
//  Created by Eno Yoo on 12/1/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

class PhotoViewModel {
    static func saveImage(item: Item, photo: Photo, data: Data) async {
        guard let id = item.id else { return }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        if photo.id == nil {
            photo.id = UUID().uuidString
        }
        metadata.contentType = "image/jpeg"
        let path = "\(id)/\(photo.id ?? "n/a")"
        
        do {
            let storageref = storage.child(path)
            let returnedMetadata = try await storageref.putDataAsync(data, metadata: metadata)
            print("Saved \(returnedMetadata)")
            
            guard let url = try? await storageref.downloadURL() else {
                print("Error: could not download URL")
                return
            }
            
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            let db = Firestore.firestore()
            do {
                try db.collection("items").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
            } catch {
                print("Error: could not update data in items/\(id)/photos/\(photo.id ?? "n/a"). \(error.localizedDescription)")
            }
            
        } catch {
            print("Error saving photo to storage: \(error.localizedDescription)")
        }
    }
    
    static func deleteImage(item: Item, photo: Photo) async {
        guard let itemID = item.id, let photoID = photo.id else { return }
        
        let storage = Storage.storage().reference()
        let path = "\(itemID)/\(photoID)"
        
        do {
            try await storage.child(path).delete()
            let db = Firestore.firestore()
            try await db.collection("items")
                .document(itemID)
                .collection("photos")
                .document(photoID)
                .delete()
            
            print("Photo deleted successfully")
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }
    
    
}
