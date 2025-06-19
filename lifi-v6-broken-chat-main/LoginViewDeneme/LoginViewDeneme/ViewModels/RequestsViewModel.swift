//
//  RequestsViewModel.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.04.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Request ViewModel (Değişiklik yok - öncekiyle aynı)
class RequestsViewModel: ObservableObject {
    @Published var requests: [Request] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    // loadRequests, fetchUserDetails, updateRequestStatus, ensureChatSessionExists
    // fonksiyonları önceki yanıttaki gibi ("Option 1" veri yapısına uygun) kalacak...

    func loadRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("RequestsViewModel: No user logged in."); self.isLoading = false; self.errorMessage = "Please log in."; return
        }
        print("RequestsViewModel: Loading requests for user \(currentUserId)")
        isLoading = true; errorMessage = nil

        db.collection("Requests")
            .whereField("toUserUID", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "Pending")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                 guard let self = self else { return }
                 if let error = error {
                     print("Error loading requests: \(error.localizedDescription)")
                      // Index hatası kontrolü
                     if let firestoreError = error as NSError?, firestoreError.code == FirestoreErrorCode.failedPrecondition.rawValue {
                         self.errorMessage = "DB Error: Missing Index. Check Console."
                     } else { self.errorMessage = "Failed to load requests." }
                     DispatchQueue.main.async { self.isLoading = false }; return
                 }
                 guard let documents = snapshot?.documents else {
                     print("No request documents snapshot."); DispatchQueue.main.async { self.requests = []; self.isLoading = false }; return
                 }
                 if documents.isEmpty { print("No pending requests found."); DispatchQueue.main.async { self.requests = []; self.isLoading = false }; return }

                 var loadedRequests: [Request] = []
                 let group = DispatchGroup()
                 print("Processing \(documents.count) requests...")
                 for doc in documents {
                    let data = doc.data(); guard let ts = data["timestamp"] as? Timestamp else { continue }
                    let fromId = data["fromUserUID"] as? String ?? ""; let toId = data["toUserUID"] as? String ?? ""
                    let eventId = data["eventID"] as? String ?? ""; let status = data["status"] as? String ?? "Pending"
                    let eventName = data["eventName"] as? String ?? "Unknown Event"
                    if !fromId.isEmpty {
                         group.enter()
                         self.fetchUserDetails(userId: fromId) { name, surname in
                              let req = Request(id: doc.documentID, fromUserId: fromId, toUserId: toId, eventId: eventId, status: status, timestamp: ts, fromUserName: name, fromUserSurname: surname, eventName: eventName)
                              loadedRequests.append(req); group.leave()
                         }
                    } else { print("Skipping req \(doc.documentID): empty fromUserId.") }
                 }
                 group.notify(queue: .main) {
                     print("Finished processing requests."); self.requests = loadedRequests; self.isLoading = false
                 }
            }
    }

    private func fetchUserDetails(userId: String, completion: @escaping (String, String) -> Void) {
         guard !userId.isEmpty else { completion("Unknown", "User"); return }
         db.collection("Users").document(userId).getDocument { userSnapshot, userError in
             var name = "Unknown"; var surname = "User"
             if let userError = userError { print("Error fetching user \(userId): \(userError.localizedDescription)") }
             else if let userDoc = userSnapshot, userDoc.exists, let data = userDoc.data() {
                 name = data["name"] as? String ?? "Unknown"; surname = data["surname"] as? String ?? ""
             } else { print("User doc not found for \(userId)") }
             completion(name, surname)
         }
    }

    func updateRequestStatus(_ requestId: String, status: String, completion: ((Bool) -> Void)? = nil) {
            print("Updating req \(requestId) to \(status)")
            db.collection("Requests").document(requestId).updateData(["status": status]) { [weak self] error in
                 guard let self = self else { completion?(false); return }
                 if let error = error { print("Error updating req status \(requestId): \(error.localizedDescription)"); completion?(false); return }
                 print("Req \(requestId) status updated to \(status).")
                  if status == "Accepted" {
                      self.ensureChatSessionExists(forRequestId: requestId) { success in
                          DispatchQueue.main.async { self.loadRequests(); completion?(success) } // Listeyi yenile, sonucu bildir
                      }
                  } else { DispatchQueue.main.async { self.loadRequests(); completion?(true) } } // Reddedilince yenile, başarılı dön
            }
        }

    // Firestore yapısı "Option 1"e göre (participants, timestamp vb. içeriyor)
        private func ensureChatSessionExists(forRequestId requestId: String, completion: @escaping (Bool) -> Void) {
             print("Ensuring chat session for req: \(requestId)")
             db.collection("Requests").document(requestId).getDocument { [weak self] snapshot, error in
                 guard let self = self else { completion(false); return }
                 if let error = error { print("Error fetching req data: \(error.localizedDescription)"); completion(false); return }
                 guard let data = snapshot?.data(), let fromId = data["fromUserUID"] as? String, let toId = data["toUserUID"] as? String, !fromId.isEmpty, !toId.isEmpty else {
                     print("Invalid req data for chat creation (req ID: \(requestId))."); completion(false); return
                 }
                 let user1 = min(fromId, toId); let user2 = max(fromId, toId)
                 print("Checking/Creating session for users: \(user1), \(user2)")
                 let chatRef = self.db.collection("ChatSessions")
                 let query = chatRef.whereField("user1", isEqualTo: user1).whereField("user2", isEqualTo: user2).limit(to: 1)
                 query.getDocuments { querySnapshot, error in
                     if let error = error { print("Error checking sessions: \(error.localizedDescription)"); completion(false); return }
                     if let documents = querySnapshot?.documents, documents.isEmpty {
                         print("Creating new chat session...")
                         let ts = Timestamp(); let data = ["user1": user1, "user2": user2, "participants": [user1, user2], "createdAt": ts, "lastMessageContent": "", "lastMessageTimestamp": ts] as [String: Any]
                         chatRef.addDocument(data: data) { error in
                              if let e = error { print("Error creating session: \(e.localizedDescription)"); completion(false) }
                              else { print("Session created."); completion(true) }
                         }
                     } else { print("Session already exists."); completion(true) } // Session zaten var
                 }
             }
        }
} // ViewModel sonu
