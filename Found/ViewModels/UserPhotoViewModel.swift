//
//  UserPhotoViewModel.swift
//  Found
//
//  Created by Eno Yoo on 12/4/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

class UserPhotoViewModel {
    static func saveImage(user: User, photo: Photo, data: Data) async {
        guard let id = user.id else { return }
        
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
                try db.collection("users").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
            } catch {
                print("Error: could not update data in users/\(id)/photos/\(photo.id ?? "n/a"). \(error.localizedDescription)")
            }
            
        } catch {
            print("Error saving photo to storage: \(error.localizedDescription)")
        }
    }
    
    static func deleteImage(user: User, photo: Photo) async {
        guard let userID = user.id, let photoID = photo.id else { return }
        
        let storage = Storage.storage().reference()
        let path = "\(userID)/\(photoID)"
        
        do {
            try await storage.child(path).delete()
            let db = Firestore.firestore()
            try await db.collection("users")
                .document(userID)
                .collection("photos")
                .document(photoID)
                .delete()
            
            print("Photo deleted successfully")
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }
    
    
}

