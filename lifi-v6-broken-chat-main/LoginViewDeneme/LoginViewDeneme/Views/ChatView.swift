import SwiftUI
import FirebaseFirestore
import FirebaseAuth


// --- ChatView Struct (ViewModel'i @StateObject ile başlatır) ---
struct ChatView: View {
    @StateObject var viewModel: ChatViewModel // <-- StateObject KULLANILIYOR
    @State private var message: String = ""
    // @Environment(\.dismiss) var dismiss // Artık Navigation tarafından yönetiliyor

    // ChatView'ı ID'lerle başlatan init metodu
    init(currentUserId: String, recipientUserId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(currentUserId: currentUserId, recipientUserId: recipientUserId))
        print("ChatView init called for recipient: \(recipientUserId)")
    }

    var body: some View {
        // En dıştaki NavigationView KALDIRILDI
        VStack(spacing: 0) {
            if !viewModel.chatSessionExists && !viewModel.recipientName.contains("Error") {
                Text("Chat session not found...")
                    .foregroundColor(.red).padding()
            }
            messageListView
            messageInputView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Toolbar içeriği aynı kalıyor
            ToolbarItem(placement: .principal) { chatHeaderView }
        }
        .onAppear {
            print("ChatView appeared. ViewModel recipient: \(viewModel.recipientUserId)")
            // Artık listener'lar ViewModel init içinde yönetiliyor
            // viewModel.startListening() // findExistingChatSessionId içinde çağrılıyor
        }
        // .onDisappear { viewModel.stopListening() } // deinit içinde yapılıyor
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.container, edges: .bottom))
    }

    // Diğer private view ve fonksiyonlar (chatHeaderView, messageListView vb.) aynı kalır...
     private var chatHeaderView: some View {
         HStack(spacing: 10) {
              if let urlString = viewModel.recipientProfileImageURL, let url = URL(string: urlString) {
                  AsyncImage(url: url) { phase in /* ... */
                      switch phase {
                      case .empty: ProgressView().frame(width: 36, height: 36)
                      case .success(let image): image.resizable().scaledToFill().frame(width: 36, height: 36).clipShape(Circle())
                      case .failure: defaultRecipientProfileIcon()
                      @unknown default: EmptyView()
                      }
                  }
              } else { defaultRecipientProfileIcon() }
             Text("\(viewModel.recipientName) \(viewModel.recipientSurname)".trimmingCharacters(in: .whitespaces))
                 .font(.headline).lineLimit(1)
             Spacer()
         }.frame(height: 44)
     }
     @ViewBuilder private func defaultRecipientProfileIcon() -> some View { /* ... */
          Image(systemName: "person.circle.fill")
               .resizable().scaledToFit().frame(width: 36, height: 36).foregroundColor(.gray)
     }
     private var messageListView: some View { /* ... */
          ScrollViewReader { proxy in
               ScrollView { VStack(spacing: 0) { ForEach(viewModel.messages) { msg in messageBubble(for: msg).id(msg.id) } }.padding(.top, 10).padding(.bottom, 5) }
               .onTapGesture(perform: hideKeyboard)
               .onChange(of: viewModel.messages.count) { _ in scrollToBottom(proxy: proxy) }
               .onChange(of: viewModel.messages.last?.id) { _ in scrollToBottom(proxy: proxy) }
          }
     }
     private func messageBubble(for msg: ChatMessage) -> some View { /* ... */
           HStack {
                if msg.fromUserId == viewModel.currentUserId { Spacer(minLength: 50) }
                VStack(alignment: msg.fromUserId == viewModel.currentUserId ? .trailing : .leading, spacing: 2) {
                     Text(msg.content).padding(.horizontal, 12).padding(.vertical, 8)
                         .background(msg.fromUserId == viewModel.currentUserId ? Color.blue : Color(UIColor.secondarySystemBackground))
                         .foregroundColor(msg.fromUserId == viewModel.currentUserId ? .white : .primary)
                         .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                     Text(msg.timestamp, style: .time).font(.caption2).foregroundColor(.gray)
                }.shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                if msg.fromUserId != viewModel.currentUserId { Spacer(minLength: 50) }
           }.padding(.horizontal).padding(.vertical, 4)
      }
     private var messageInputView: some View { /* ... */
          HStack(spacing: 10) {
               TextField("Type a message...", text: $message, axis: .vertical)
                    .lineLimit(1...5).padding(8)
                    .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
               Button(action: sendMessageAction) {
                    Image(systemName: "arrow.up.circle.fill").resizable().scaledToFit().frame(width: 32, height: 32)
                         .foregroundColor(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
               }.disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          }.padding(.horizontal).padding(.vertical, 8).background(.thinMaterial)
     }
     private func sendMessageAction() { /* ... */
         let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
         if !trimmedMessage.isEmpty { viewModel.sendMessage(content: trimmedMessage); message = "" }
     }
     private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) { /* ... */
          guard let lastId = viewModel.messages.last?.id else { return }
          if animated { withAnimation(.smooth) { proxy.scrollTo(lastId, anchor: .bottom) } } // .smooth eklendi
          else { proxy.scrollTo(lastId, anchor: .bottom) }
     }
     private func hideKeyboard() { /* ... */
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }

} // ChatView Struct Sonu
// -----------------------------------------------------------


// --- Preview Provider (init kullanır) ---
#Preview {
     ChatView(currentUserId: "user1_preview", recipientUserId: "user2_preview")
}
// --------------------------------------
