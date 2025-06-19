import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine // Cancelables için

// ChatSessionInfo struct'ının burada veya ayrı bir dosyada tanımlı olduğunu varsayıyoruz
// Örnek:
/*
 struct ChatSessionInfo: Identifiable, Hashable {
     let id: String
     let recipientUserId: String
     var recipientName: String
     var recipientSurname: String
     var recipientProfileImageURL: String?
     var lastMessageContent: String?
     var lastMessageTimestamp: Timestamp?

     func hash(into hasher: inout Hasher) { hasher.combine(id) }
     static func == (lhs: ChatSessionInfo, rhs: ChatSessionInfo) -> Bool {
         lhs.id == rhs.id && lhs.lastMessageTimestamp == rhs.lastMessageTimestamp
     }
     var formattedRecipientName: String { "\(recipientName) \(recipientSurname)".trimmingCharacters(in: .whitespaces) }
 }
 */


class ChatListViewModel: ObservableObject {
    @Published var chatSessions = [ChatSessionInfo]()
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var db = Firestore.firestore()
    private var listeners = Set<AnyCancellable>() // Şu an kullanılmıyor ama kalabilir
    private var sessionsListener: ListenerRegistration?
    private var userListeners = [String: ListenerRegistration]()

    var currentUserId: String? { Auth.auth().currentUser?.uid }

    init() {
        fetchChatSessions()
    }

    deinit {
        print("ChatListViewModel deinitialized")
        sessionsListener?.remove()
        userListeners.values.forEach { $0.remove() }
    }

    func fetchChatSessions() {
            guard let userId = currentUserId, !userId.isEmpty else {
                errorMessage = "User not logged in."
                isLoading = false // isLoading'i false yap
                return
            }

            isLoading = true
            errorMessage = nil
            sessionsListener?.remove()

            print("ChatListViewModel: Starting fetch for user \(userId)")

            // Firestore'da ChatSessions belgelerinizde "participants" alanı olduğunu varsayıyoruz
            // Eğer yoksa, bu sorgu çalışmaz ve iki ayrı sorgu gerekir.
            sessionsListener = db.collection("ChatSessions")
                .whereField("participants", arrayContains: userId)
                .order(by: "lastMessageTimestamp", descending: true) // Bu alanın belgelerde olması gerekir
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Error fetching chat sessions: \(error.localizedDescription)")
                        // Firestore index hatası olup olmadığını kontrol et
                        if let firestoreError = error as NSError?, firestoreError.code == FirestoreErrorCode.failedPrecondition.rawValue {
                             print("Firestore Index Error: Check console for link to create index.")
                             self.errorMessage = "Database error: Missing index. Check Xcode console."
                        } else {
                             self.errorMessage = "Failed to load chats."
                        }
                        self.isLoading = false
                        return
                    }

                    guard let documents = querySnapshot?.documents else {
                        print("No chat session documents snapshot found.")
                        self.isLoading = false
                        self.chatSessions = [] // Boş olduğundan emin ol
                        return
                    }

                    print("Fetched \(documents.count) chat session documents.")
                    var newSessions = documents.compactMap { doc -> ChatSessionInfo? in
                        let data = doc.data()
                        guard let participants = data["participants"] as? [String],
                              participants.count == 2,
                              let recipientUserId = participants.first(where: { $0 != userId }), // Diğer kullanıcıyı bul
                              !recipientUserId.isEmpty else {
                            print("Skipping document \(doc.documentID): Invalid participants field.")
                            return nil // Artık Optional<...>.none yerine nil kullanılabilir
                        }

                        let lastMessage = data["lastMessageContent"] as? String
                        let lastTimestamp = data["lastMessageTimestamp"] as? Timestamp

                        return ChatSessionInfo(
                                           id: doc.documentID,
                                           recipientUserId: recipientUserId,
                                           recipientName: "Loading...",
                                           recipientSurname: "",
                                           // --- DEĞİŞİKLİK BURADA ---
                                           recipientProfileImageURL: nil as String?, // nil'in tipini açıkça belirtiyoruz
                                           // -------------------------
                                           lastMessageContent: lastMessage,
                                           lastMessageTimestamp: lastTimestamp
                                       )
                    }

                    // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
                    // Ana thread'de listeyi güncelle VE SONRA detayları çekmeyi tetikle
                    DispatchQueue.main.async {
                        // Sadece gerçekten değişiklik varsa güncelleme yapmak SwiftUI performansını artırır
                        // if self.chatSessions != newSessions { // Equatable olmalı ChatSessionInfo
                             self.chatSessions = newSessions
                        // }
                        self.isLoading = false
                        print("ChatSessions array updated in ViewModel. Now fetching recipient details.")
                        // Liste güncellendikten sonra detayları çek (artık parametre almıyor)
                        self.fetchRecipientDetails() // <-- Çağrı buraya taşındı
                    }
                    // --- DEĞİŞİKLİK BURADA BİTİYOR ---
                }
        }

    // ChatListViewModel içinde

        // --- fetchRecipientDetails GÜNCELLENDİ (UI Güncellemesini Zorlamak İçin) ---
        private func fetchRecipientDetails() {
            // Mevcut dinleyicileri temizle
            userListeners.values.forEach { $0.remove() }
            userListeners.removeAll()

            guard !self.chatSessions.isEmpty else {
                print("No sessions to fetch recipient details for.")
                return
            }

            print("Fetching recipient details for \(self.chatSessions.count) sessions...")

            // self.chatSessions üzerinde DİKKATLİCE döngü kur (index kullanmak yerine ID ile)
            // For döngüsü sırasında self.chatSessions değişebileceği için index kullanmak riskli olabilir.
            // ID listesini alıp onun üzerinde dönmek daha güvenli.
            let sessionIdsAndRecipientIds = self.chatSessions.map { ($0.id, $0.recipientUserId) }

            for (_, recipientId) in sessionIdsAndRecipientIds { // session ID'si şu an kullanılmıyor ama gelecekte lazım olabilir
                guard !recipientId.isEmpty else { continue }

                // Zaten dinleyici varsa tekrar ekleme
                if userListeners[recipientId] == nil {
                    userListeners[recipientId] = db.collection("Users").document(recipientId)
                        .addSnapshotListener { [weak self] userSnapshot, error in
                            guard let self = self else { return }
                            var name = "Unknown"; var surname = "User"; var imageURL: String? = nil

                            if let userError = error {
                                 print("Error fetching details for \(recipientId): \(userError.localizedDescription)")
                                 // Hata durumunda da UI'ı güncellemek isteyebiliriz
                                 name = "Error"
                                 surname = ""
                            } else if let userDoc = userSnapshot, userDoc.exists, let userData = userDoc.data() {
                                name = userData["name"] as? String ?? "Unknown"
                                surname = userData["surname"] as? String ?? ""
                                imageURL = userData["profileImageURL"] as? String
                            } else {
                                print("Recipient details not found for \(recipientId)")
                                // Kullanıcı bulunamadıysa "Unknown User" yazsın
                            }

                            // --- Ana thread'de GÜNCELLEME (Diziyi yeniden atayarak) ---
                            DispatchQueue.main.async {
                                // Mevcut dizinin kopyasını al
                                var updatedSessions = self.chatSessions

                                // Güncellenecek session'ın index'ini KOPYA dizide bul
                                if let sessionIndex = updatedSessions.firstIndex(where: { $0.recipientUserId == recipientId }) {
                                    // Sadece gerçekten değişiklik varsa güncelle
                                    if updatedSessions[sessionIndex].recipientName != name ||
                                       updatedSessions[sessionIndex].recipientSurname != surname ||
                                       updatedSessions[sessionIndex].recipientProfileImageURL != imageURL {

                                        print("Attempting to update UI via array reassignment for \(recipientId) with name: \(name)")

                                        // Kopya dizideki elemanı güncelle
                                        updatedSessions[sessionIndex].recipientName = name
                                        updatedSessions[sessionIndex].recipientSurname = surname
                                        updatedSessions[sessionIndex].recipientProfileImageURL = imageURL

                                        // Güncellenmiş KOPYA diziyi @Published diziye ata.
                                        // Bu atama işlemi SwiftUI'ın değişikliği fark etmesini sağlamalı.
                                        self.chatSessions = updatedSessions
                                        print("UI Updated via array reassignment for \(recipientId)")
                                    }
                                } else {
                                     print("ERROR: Could not find session index for \(recipientId) in current array copy during update.")
                                }
                            }
                            // --- Güncelleme Sonu ---
                        }
                } // if userListeners[...] == nil sonu
            } // for döngüsü sonu
        } // fetchRecipientDetails fonksiyonu sonu
        // --- GÜNCELLEME SONU ---

} // ChatListViewModel Sınıfı Sonu


