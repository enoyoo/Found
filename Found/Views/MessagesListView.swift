//
//  MessagesListView.swift
//  Found
//
//  Created by Eno Yoo on 11/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MessagesListView: View {
    @FirestoreQuery(collectionPath: "conversations") var conversations: [Conversation]
    @State private var currentUserEmail = Auth.auth().currentUser?.email ?? ""
    
    var body: some View {
        NavigationStack {
            Group {
                if myConversations.isEmpty {
                    ContentUnavailableView(
                        "No Messages",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Start a conversation by messaging someone from their profile")
                    )
                } else {
                    List(myConversations) { conversation in
                        NavigationLink {
                            if let otherUserID = getOtherUser(from: conversation),
                               let conversationID = conversation.id {
                                ChatView(conversationID: conversationID, otherUserID: otherUserID)
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(getOtherUser(from: conversation)?.split(separator: "@").first.map(String.init) ?? "Unknown")
                                        .font(.title3)
                                    
                                        Text(conversation.lastMessage)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    
                                }
                                
                                Spacer()
                                
                                Text(conversation.lastMessageTime.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
        }
        .task {
            if let currentUserID = Auth.auth().currentUser?.email {
                currentUserEmail = currentUserID
                $conversations.predicates = [
                    .whereField("participants", arrayContains: currentUserID)
                ]
            }
        }
    }
    
    var myConversations: [Conversation] {
        conversations.sorted { $0.lastMessageTime > $1.lastMessageTime }
    }
    
    func getOtherUser(from conversation: Conversation) -> String? {
        return conversation.participants.first { $0 != currentUserEmail }
    }
}

#Preview {
    NavigationStack {
        MessagesListView()
    }
}
