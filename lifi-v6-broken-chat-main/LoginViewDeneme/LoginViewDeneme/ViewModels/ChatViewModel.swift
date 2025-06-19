//
//  ChatViewModel.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.04.2025.
//

import Foundation
import FirebaseFirestore


class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var recipientName: String = ""
    @Published var recipientSurname: String = ""
    @Published var recipientProfileImageURL: String? = nil
    @Published var chatSessionExists: Bool = false

    let currentUserId: String
    let recipientUserId: String

    private let db = Firestore.firestore()
    private var chatSessionId: String? = nil
    private var messageListener: ListenerRegistration?
    private var userListener: ListenerRegistration?

    init(currentUserId: String, recipientUserId: String) {
        guard !currentUserId.isEmpty, !recipientUserId.isEmpty else {
            print("ERROR: currentUserId or recipientUserId is empty in ChatViewModel init.")
            self.currentUserId = currentUserId; self.recipientUserId = recipientUserId
            self.recipientName = "Error"; self.chatSessionExists = false
            return
        }
        self.currentUserId = currentUserId
        self.recipientUserId = recipientUserId
        print("ChatViewModel initialized for recipient: \(recipientUserId)")
        fetchRecipientDetails()
        findExistingChatSessionId()
    }

    deinit {
        print("ChatViewModel deinitialized for recipient: \(recipientUserId)")
        stopListening()
        userListener?.remove()
    }

    func fetchRecipientDetails() {
        guard !recipientUserId.isEmpty else { return }
        userListener?.remove()
        print("Starting listener for recipient details: \(recipientUserId)")
        userListener = db.collection("Users").document(recipientUserId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                if let error = error { print("Error fetching recipient: \(error.localizedDescription)"); DispatchQueue.main.async { self.updateRecipientInfo(name: "Error", surname: "", url: nil) }; return }
                guard let document = documentSnapshot, document.exists, let data = document.data() else { print("Recipient doc not found for \(self.recipientUserId)"); DispatchQueue.main.async { self.updateRecipientInfo(name: "Unknown", surname: "User", url: nil) }; return }
                DispatchQueue.main.async { self.updateRecipientInfo(name: data["name"] as? String, surname: data["surname"] as? String, url: data["profileImageURL"] as? String) }
            }
    }

    private func updateRecipientInfo(name: String?, surname: String?, url: String?) {
        self.recipientName = name ?? "No Name"; self.recipientSurname = surname ?? ""; self.recipientProfileImageURL = url
    }

    private func findExistingChatSessionId() {
        let user1 = min(currentUserId, recipientUserId); let user2 = max(currentUserId, recipientUserId)
        print("Finding session for users: \(user1), \(user2)")
        db.collection("ChatSessions")
            .whereField("user1", isEqualTo: user1).whereField("user2", isEqualTo: user2).limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { print("Error finding session: \(error.localizedDescription)"); DispatchQueue.main.async { self.chatSessionExists = false }; return }
                if let document = snapshot?.documents.first {
                    print("Session found: \(document.documentID)")
                    let foundId = document.documentID
                    DispatchQueue.main.async {
                        self.chatSessionExists = true
                        if self.chatSessionId != foundId { self.chatSessionId = foundId; self.startListening() }
                    }
                } else {
                    print("Session NOT found between \(user1), \(user2).");
                    DispatchQueue.main.async { self.chatSessionExists = false; self.chatSessionId = nil; self.stopListening(); self.messages = [] }
                }
            }
    }

    func startListening() {
        guard chatSessionExists, let sessionId = chatSessionId, messageListener == nil else { return }
        print("Starting message listener for session: \(sessionId)")
        observeMessages(chatSessionId: sessionId)
    }

    func stopListening() { messageListener?.remove(); messageListener = nil }

    private func observeMessages(chatSessionId: String) {
        messageListener = db.collection("ChatSessions").document(chatSessionId).collection("messages")
            .order(by: "timestamp", descending: false).limit(toLast: 100)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error { print("Error observing messages: \(error.localizedDescription)"); return }
                guard let snapshot = querySnapshot else { return }
                self.messages = snapshot.documents.compactMap { doc -> ChatMessage? in
                    let data = doc.data(); guard let ts = data["timestamp"] as? Timestamp else { return nil }
                    return ChatMessage(id: doc.documentID, fromUserId: data["fromUserId"] as? String ?? "", content: data["content"] as? String ?? "", timestamp: ts.dateValue())
                }
            }
    }

    func sendMessage(content: String) {
         let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
         guard !trimmedContent.isEmpty else { return }
        guard let sessionId = chatSessionId else { return }
        print("Sending message to session: \(sessionId)")
        let messageData = ["fromUserId": currentUserId, "content": trimmedContent, "timestamp": FieldValue.serverTimestamp()] as [String: Any]
        db.collection("ChatSessions").document(sessionId).collection("messages").addDocument(data: messageData) { [weak self] error in
            guard let self = self else { return }
            if let error = error { print("Error sending message: \(error.localizedDescription)") }
            else { print("Message sent."); self.updateLastMessageInfo(chatSessionId: sessionId, message: trimmedContent) }
        }
    }

    private func updateLastMessageInfo(chatSessionId: String, message: String) {
        guard !chatSessionId.isEmpty else { return }
        db.collection("ChatSessions").document(chatSessionId).updateData([
            "lastMessageContent": message, "lastMessageTimestamp": FieldValue.serverTimestamp()]) { error in
            if let error = error { print("Error updating last message: \(error.localizedDescription)") }
            else { print("Updated last message for session \(chatSessionId)") }
        }
    }
}
