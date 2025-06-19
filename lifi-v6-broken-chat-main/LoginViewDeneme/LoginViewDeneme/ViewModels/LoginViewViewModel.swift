import Foundation
import FirebaseAuth

class LoginViewViewModel : ObservableObject {

    @Published var email : String = ""
    @Published var password : String = ""
    @Published var errorMessage : String = ""
    @Published var showAlert: Bool = false

    init() {}

    func validate() -> Bool {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines) // ← EKLENDİ
        password = password.trimmingCharacters(in: .whitespacesAndNewlines) // ← EKLENDİ
        errorMessage = ""

        if email.isEmpty || password.isEmpty {
            errorMessage = "Email and password cannot be empty."
            showAlert = true
            return false
        } else if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address."
            showAlert = true
            return false
        } else if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            showAlert = true
            return false
        }

        return true
    }

    func login() {
        showAlert = false
        errorMessage = ""

        guard validate() else {
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    let errorCode = AuthErrorCode(rawValue: error.code)
                    switch errorCode {
                    case .wrongPassword:
                        self?.errorMessage = "Incorrect password. Please try again."
                    case .invalidEmail:
                        self?.errorMessage = "Invalid email format."
                    case .userNotFound:
                        self?.errorMessage = "No account found with this email."
                    case .userDisabled:
                        self?.errorMessage = "Your account has been disabled."
                    case .tooManyRequests:
                        self?.errorMessage = "Too many login attempts. Try again later."
                    case .networkError:
                        self?.errorMessage = "Network connection error."
                    default:
                        self?.errorMessage = error.localizedDescription
                    }

                    self?.showAlert = true
                } else {
                    print("✅ Login successful")
                    // Başarılı giriş sonrası işlem
                }
            }
        }
    }
}
