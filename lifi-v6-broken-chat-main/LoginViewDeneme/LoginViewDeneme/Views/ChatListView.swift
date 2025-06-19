import SwiftUI
import FirebaseFirestore // Timestamp için
import FirebaseAuth     // currentUserId için



struct ChatListView: View {
    // ViewModel'i StateObject olarak başlatıyoruz
    // ChatListViewModel'in ayrı bir dosyada tanımlı olduğunu varsayıyoruz
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        // NavigationStack (iOS 16+) veya NavigationView
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading chats...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red).padding()
                } else if viewModel.chatSessions.isEmpty {
                    Text("No active chats found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.chatSessions) { sessionInfo in
                            // NavigationLink artık sadece değeri iletiyor
                            NavigationLink(value: sessionInfo.recipientUserId) {
                                ChatListRow(sessionInfo: sessionInfo)
                            }
                        }
                    }
                    .listStyle(.plain)
                    // Navigasyon hedefini burada tanımlıyoruz
                    .navigationDestination(for: String.self) { recipientId in
                         // Gelen recipientId ile ChatView'ı başlatıyoruz
                        ChatView(
                            currentUserId: viewModel.currentUserId ?? "", // Geçerli kullanıcıyı da gönder
                            recipientUserId: recipientId
                        )
                    }
                }
            }
            .navigationTitle("Chats")
            .onAppear {
                print("ChatListView appeared.")
                // Liste her göründüğünde yenilemek yerine listener ile güncelleme beklenir.
                // Gerekirse manuel yenileme butonu eklenebilir.
                // viewModel.fetchChatSessions() // init'te çağrıldığı için genellikle gerekmez
            }
        } // NavigationStack sonu
    }
}


// ---------------------------------------------------

// --- Preview ---
#Preview {
    // Preview için ChatListViewModel mock data ile başlatılabilir
    ChatListView()
}
// ---------------

