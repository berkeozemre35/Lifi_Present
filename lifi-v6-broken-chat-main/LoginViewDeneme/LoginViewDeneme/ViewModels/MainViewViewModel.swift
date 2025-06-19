import Foundation
import FirebaseAuth

class MainViewViewModel : ObservableObject {
    @Published var currentUserId : String = ""
    @Published var isSignedIn : Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                self?.isSignedIn = (user != nil)
                print("✅ Giriş durumu: \(self?.isSignedIn ?? false)")
            }
        }
    }
}
