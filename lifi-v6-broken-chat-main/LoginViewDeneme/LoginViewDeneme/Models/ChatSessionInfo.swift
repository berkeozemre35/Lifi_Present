import Foundation
import FirebaseCore

struct ChatSessionInfo: Identifiable, Hashable {
    let id: String // ChatSession Document ID
    let recipientUserId: String
    var recipientName: String
    var recipientSurname: String
    var recipientProfileImageURL: String?
    var lastMessageContent: String?
    var lastMessageTimestamp: Timestamp?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ChatSessionInfo, rhs: ChatSessionInfo) -> Bool {
        // Sadece ID ve son mesaj zamanı değiştiğinde güncelleme (performans için)
        // Veya daha fazla alanı kontrol edebilirsiniz.
        lhs.id == rhs.id && lhs.lastMessageTimestamp == rhs.lastMessageTimestamp
    }
    var formattedRecipientName: String { "\(recipientName) \(recipientSurname)".trimmingCharacters(in: .whitespaces) }
}
