//
//  MessagesViewModel.swift
//  Found
//
//  Created by Eno Yoo on 12/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessagesViewModel {
    
    static func getConversation(otherUserID: String) async -> String? {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.email else { return nil }
        let participants = [currentUserID, otherUserID].sorted()
        
        do {
            let snapshot = try await db.collection("conversations")
                .whereField("participants", isEqualTo: participants)
                .getDocuments()
            
            if let existingConversation = snapshot.documents.first {
                return existingConversation.documentID
            }
            
            let newConversation = Conversation(
                participants: participants,
                lastMessage: "",
                lastMessageTime: Date(),
                lastMessageSenderID: currentUserID
            )
            
            let docRef = try db.collection("conversations").addDocument(from: newConversation)
            return docRef.documentID
            
        } catch {
            print("Error getting/creating conversation: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    static func sendMessage(conversationID: String, text: String, receiverID: String) async {
        guard let senderID = Auth.auth().currentUser?.email else { return }
        
        let db = Firestore.firestore()
        
        let message = Message(
            text: text,
            senderID: senderID,
            time: Date()
        )
        
        do {
            try db.collection("conversations")
                .document(conversationID)
                .collection("messages")
                .addDocument(from: message)
            
            try await db.collection("conversations")
                .document(conversationID)
                .updateData([
                    "lastMessage": text,
                    "lastMessageTime": Date(),
                    "lastMessageSenderID": senderID
                ])
            
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}
