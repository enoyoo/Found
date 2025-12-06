//
//  Conversation.swift
//  Found
//
//  Created by Eno Yoo on 12/5/25.
//

import Foundation
import FirebaseFirestore

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String] // Array of user emails
    var lastMessage: String
    var lastMessageTime: Date
    var lastMessageSenderID: String
}
