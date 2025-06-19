import SwiftUI
import FirebaseAuth
import FirebaseFirestore




// RequestsContentView UI (.sheet içindeki ChatView çağrısı düzeltildi)
struct RequestsContentView: View {
    @ObservedObject var viewModel: RequestsViewModel
    @State private var showingChatForUserId: String? = nil
    @State private var showChatSheet: Bool = false

    var body: some View {
         NavigationStack {
              VStack {
                   if viewModel.isLoading { ProgressView("Loading...").padding() }
                   else if let errMsg = viewModel.errorMessage { Text(errMsg).foregroundColor(.red).padding() }
                   else if viewModel.requests.isEmpty { Text("No pending requests.").foregroundColor(.gray).padding() }
                   else {
                        List(viewModel.requests) { request in
                             HStack {
                                  VStack(alignment: .leading, spacing: 4) {
                                       Text("From: \(request.fromUserName) \(request.fromUserSurname)".trimmingCharacters(in: .whitespaces))
                                            .fontWeight(.semibold)
                                       Text("Event: \(request.eventName)")
                                            .font(.subheadline).foregroundColor(.secondary)
                                  }
                                  Spacer()
                                  HStack(spacing: 15) {
                                       Button("Accept") {
                                            viewModel.updateRequestStatus(request.id, status: "Accepted") { success in
                                                 if success {
                                                      print("Req accepted, show sheet for \(request.fromUserId)")
                                                      self.showingChatForUserId = request.fromUserId
                                                      self.showChatSheet = true
                                                 } else { print("Failed to accept/create session.") }
                                            }
                                       }
                                       .buttonStyle(.borderedProminent).tint(.green).controlSize(.small)

                                       Button("Reject") {
                                            viewModel.updateRequestStatus(request.id, status: "Rejected")
                                       }
                                       .buttonStyle(.bordered).tint(.red).controlSize(.small)
                                  }
                             }
                             .padding(.vertical, 8)
                        }
                        .listStyle(.plain)
                   }
              } // Ana VStack sonu
              .navigationTitle("Join Requests")
              .navigationBarTitleDisplayMode(.inline)
              .onAppear { viewModel.loadRequests() }
              // --- .sheet Modifier (ChatView çağrısı düzeltildi) ---
              .sheet(isPresented: $showChatSheet, onDismiss: { showingChatForUserId = nil }) {
                   if let recipientId = showingChatForUserId {
                        // ChatView'ı DOĞRU init ile çağırıyoruz
                        ChatView(
                            currentUserId: Auth.auth().currentUser?.uid ?? "",
                            recipientUserId: recipientId
                        )
                   } else {
                        Text("Error: Missing recipient user ID.").padding()
                   }
              }
              // -----------------------------------------
         } // NavigationStack sonu
    } // body sonu
} // RequestsContentView struct sonu


// Preview Provider (Değişiklik yok)
struct RequestsContentView_Previews: PreviewProvider {
     static var previews: some View {
         let previewViewModel = RequestsViewModel()
          NavigationView {
             RequestsContentView(viewModel: previewViewModel)
         }
     }
 }

