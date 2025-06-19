//
//  RegisterViewViewModel.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 13.12.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel : ObservableObject {
    
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = "" // Hata mesajını gösterebilmek için ekledik
    
    init() {}
        
    
    func registerUser() {
        guard validate() else {
        return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self ] result,error in
            guard let userId = result?.user.uid else {
                return
            }
            // Insert methodu çağırılacak
            self?.insertUserRecord(id: userId)
        }
        
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id, name: name, surname: surname, email: email, joined: Date().timeIntervalSince1970)
        let db = Firestore.firestore()

        // Kullanıcı temel bilgilerini kaydet
        db.collection("Users").document(id).setData(newUser.asDictictionary()) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User saved successfully!")
            }
        }

        // Varsayılan biyografi ekle
        db.collection("Users").document(id).updateData([
            "biography": "This is my default biography."
        ]) { error in
            if let error = error {
                print("Error saving biography: \(error.localizedDescription)")
            } else {
                print("Biography saved successfully!")
            }
        }
    }
    
    
    private func validate() -> Bool {
            // Boş alan kontrolü
            if name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                errorMessage = "All fields must be filled."
                return false
            }
            
            // E-posta formatını kontrol et
            if !email.contains("@") {
                errorMessage = "Please enter a valid email address."
                return false
            }
            
            // Şifre uzunluğunu kontrol et
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters."
                return false
            }
            
            // Şifre ve şifre onayı eşleşip eşleşmediğini kontrol et
            if password != confirmPassword {
                errorMessage = "Passwords do not match."
                return false
            }
            
            // Eğer tüm kontroller geçer, burada Firebase'e kayıt işlemi yapılabilir
            errorMessage = ""  // Hata mesajını temizle
            print("Registration Successful")
        return true
        }
    
    
}
