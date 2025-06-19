

import SwiftUI

struct ChatListRow: View {
    let sessionInfo: ChatSessionInfo
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: sessionInfo.recipientProfileImageURL ?? "")) { phase in
                switch phase {
                case .empty: ProgressView().frame(width: 50, height: 50)
                case .success(let image): image.resizable().scaledToFill().frame(width: 50, height: 50).clipShape(Circle())
                case .failure: Image(systemName: "person.circle.fill").resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.gray)
                @unknown default: EmptyView()
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(sessionInfo.formattedRecipientName).font(.headline).lineLimit(1)
                if let lastMessage = sessionInfo.lastMessageContent, !lastMessage.isEmpty {
                    Text(lastMessage).font(.subheadline).foregroundColor(.gray).lineLimit(1)
                } else { Text(" ").font(.subheadline) }
            }
            Spacer()
            if let timestamp = sessionInfo.lastMessageTimestamp {
                Text(timestamp.dateValue(), style: .time).font(.caption).foregroundColor(.gray)
            }
        }.padding(.vertical, 4)
    }
}

#Preview {
    // Preview için ChatListViewModel mock data ile başlatılabilir
    ChatListView()
}
