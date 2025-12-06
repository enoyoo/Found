//
//  ChatView.swift
//  Found
//
//  Created by Eno Yoo on 12/5/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatView: View {
    let conversationID: String
    let otherUserID: String
    
    @FirestoreQuery(collectionPath: "conversations") var messages: [Message]
    @State private var messageText = ""
    @State private var currentUserEmail = Auth.auth().currentUser?.email ?? ""
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, currentUserEmail: currentUserEmail)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    // Scroll to bottom when new message arrives
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Scroll to bottom on appear
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            // Message input
            HStack(spacing: 12) {
                TextField("Message", text: $messageText, axis: .vertical)
                    .font(.title3)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .padding(.leading)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .buttonStyle(.glassProminent)
                        .font(.title)
                        .foregroundStyle(.blue)
                }
                .disabled(messageText.isEmpty)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Button(otherUserID.split(separator: "@").first.map(String.init) ?? otherUserID) {
                    sheetIsPresented.toggle()
                }
                .bold()
            }
        }
        .sheet(isPresented: $sheetIsPresented) {
            NavigationStack {
                ProfileView(item: Item(userID: otherUserID))
            }
        }
        .task {
            $messages.path = "conversations/\(conversationID)/messages"
            $messages.predicates = [.order(by: "time", descending: false)]
        }
    }
    
    func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            await MessagesViewModel.sendMessage(
                conversationID: conversationID,
                text: text,
                receiverID: otherUserID
            )
            messageText = ""
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let currentUserEmail: String
    
    private var isFromCurrentUser: Bool {
        message.senderID == currentUserEmail
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundStyle(isFromCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(message.time.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !isFromCurrentUser { Spacer() }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(conversationID: "preview", otherUserID: "eno.yoo@bc.edu")
    }
}
