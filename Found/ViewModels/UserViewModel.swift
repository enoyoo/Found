//
//  UserViewModel.swift
//  Found
//
//  Created by Eno Yoo on 12/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel {
    static func saveUser(user: User) async -> String? {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else { return nil }
        
        do {
            try db.collection("users").document(email).setData(from: user)
            return email
        } catch {
            print("Error saving user: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func createUser() async {
        guard let email = Auth.auth().currentUser?.email else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let existingUser = await getCurrentUser()
        if existingUser == nil {
            let newUser = User(
                username: email.split(separator: "@", maxSplits: 1).first.map(String.init) ?? "",
                email: email,
                userID: uid
            )
            
            _ = await saveUser(user: newUser)
        }
    }
    
    static func getCurrentUser() async -> User? {
        guard let email = Auth.auth().currentUser?.email else { return nil }
        
        let db = Firestore.firestore()
        do {
            let document = try await db.collection("users").document(email).getDocument()
            return try? document.data(as: User.self)
        } catch {
            print("Error getting user: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func getUser(byEmail email: String) async -> User? {
            let db = Firestore.firestore()
            do {
                let document = try await db.collection("users").document(email).getDocument()
                return try? document.data(as: User.self)
            } catch {
                print("Error getting user: \(error.localizedDescription)")
                return nil
            }
        }
}
