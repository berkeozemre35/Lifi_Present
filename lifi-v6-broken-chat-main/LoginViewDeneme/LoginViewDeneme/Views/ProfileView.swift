//
//  ProfileView.swift
//  LoginViewDeneme
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State private var selectedSegment: Segment = .profile // Segment state'i
    @State private var userName: String = "Guest" // Varsayılan kullanıcı adı
    @State private var bio: String = "Write your biography here..."
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil // Seçilen profil resmi
    @State private var isNewImageSelected: Bool = false

    // --- Alert için State Değişkenleri ---
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    // ------------------------------------

    enum Segment {
        case profile, settings
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Kontrolü
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            selectedSegment = .profile
                        }
                    }) {
                        Text("About")
                            .foregroundColor(selectedSegment == .profile ? .black : .gray)
                            .fontWeight(selectedSegment == .profile ? .bold : .regular)
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }

                    Button(action: {
                        withAnimation {
                            selectedSegment = .settings
                        }
                    }) {
                        Text("Settings")
                            .foregroundColor(selectedSegment == .settings ? .black : .gray)
                            .fontWeight(selectedSegment == .settings ? .bold : .regular)
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            if selectedSegment == .settings { Spacer() }
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width / 2, height: 4)
                                .foregroundColor(.blue)
                            if selectedSegment == .profile { Spacer() }
                        }
                    }
                )

                Divider()

                // İçerik Görünümü
                if selectedSegment == .profile {
                    VStack {
                        // Profil Fotoğrafı Alanı
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 120, height: 120)
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    .shadow(radius: 5)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text("Add Photo")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .medium))
                                    )
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.top, 20)
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(image: $selectedImage, isNewImageSelected: $isNewImageSelected)
                        }

                        // Kullanıcı Adı ve Soyadı
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 10)

                        // --- Profil Resmini Kaydetme (Alert eklendi) ---
                        if let selectedImage = selectedImage, isNewImageSelected {
                            Button(action: {
                                uploadProfileImage(image: selectedImage) { result in
                                    switch result {
                                    case .success(let url):
                                        // Yükleme başarılı, şimdi URL'yi Firestore'a kaydet
                                        saveProfileImageURL(url: url) { error in
                                            // saveProfileImageURL zaten alert'i ayarlıyor
                                            if let error = error {
                                                 // Firestore kaydetme hatası (saveProfileImageURL içinde handle ediliyor)
                                                print("Firestore save failed (alert handled in saveProfileImageURL): \(error.localizedDescription)")
                                            } else {
                                                 // Firestore kaydetme başarılı (saveProfileImageURL içinde handle ediliyor)
                                                print("Firestore save successful (alert handled in saveProfileImageURL)")
                                            }
                                        }
                                    case .failure(let error):
                                        // Yükleme veya URL alma başarısız oldu, HATA alert'i göster
                                        print("Failed to upload image or get URL: \(error.localizedDescription)")
                                        self.alertTitle = "Upload Error"
                                        self.alertMessage = "Failed to upload profile photo: \(error.localizedDescription)"
                                        self.showAlert = true // Alert'i göster
                                    }
                                }
                            }) {
                                Text("Save Profile Photo")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 10)
                        }
                        // ------------------------------------------------

                        // Biyografi Alanı
                        VStack(alignment: .leading) {
                            Text("Biography")
                                .font(.headline)
                                .padding(.bottom, 8)
                            TextEditor(text: $bio)
                                .frame(height: 150)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Biyografiyi Kaydet Butonu
                        Button(action: {
                            updateBiography() // Bu fonksiyon kendi alert'ini tetikler
                        }) {
                            Text("Save Biography")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        Spacer()
                    }
                } else {
                    // Settings View içeriği
                    NavigationLink(destination: SettingsView()) {
                        EmptyView()
                    }
                    .hidden()
                    SettingsView()
                }

                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarHidden(true)
            .onAppear {
                fetchUserName()
            }
            // --- Alert Modifier'ı (Hem biyografi hem de profil resmi için kullanılır) ---
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            // ---------------------------------------------------------------------------
        }
    }

    // Kullanıcı adını ve profil resmini Firestore'dan al
    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("Users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? "Guest"
                let surname = data?["surname"] as? String ?? ""
                let biography = data?["biography"] as? String ?? "Write your biography here..."

                userName = "\(name) \(surname)"
                bio = biography

                if let profileImageURLString = data?["profileImageURL"] as? String,
                   let url = URL(string: profileImageURLString) {
                    fetchImage(from: url) { image in
                        selectedImage = image
                    }
                } else {
                     // Eğer Firestore'da URL yoksa, selectedImage'ı nil yap
                     selectedImage = nil
                }
            } else {
                print("Document does not exist")
                bio = "Write your biography here..."
                selectedImage = nil // Belge yoksa fotoğrafı da sıfırla
            }
        }
    }

    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in // Hata kontrolü eklendi
             DispatchQueue.main.async { // Ana thread'e geçiş sağlandı
                 if let error = error {
                     print("Error fetching image data: \(error.localizedDescription)")
                     completion(nil)
                     return
                 }
                 if let data = data, let image = UIImage(data: data) {
                     completion(image)
                 } else {
                     print("Could not decode image data from URL: \(url)")
                     completion(nil)
                 }
             }
        }.resume()
    }

    private func uploadProfileImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
             let error = NSError(domain: "AppErrorDomain", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(.failure(error))
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let error = NSError(domain: "AppErrorDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
            completion(.failure(error))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Firebase Storage upload error: \(error.localizedDescription)")
                completion(.failure(error)) // Firebase'den gelen hatayı doğrudan ilet
                return
            }

            // Yükleme başarılı, şimdi indirme URL'sini alalım
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Firebase Storage download URL error: \(error.localizedDescription)")
                    completion(.failure(error)) // Firebase'den gelen hatayı doğrudan ilet
                } else if let url = url {
                    completion(.success(url)) // Başarılı URL'yi ilet
                } else {
                    // Bu durum normalde olmamalı ama yine de kontrol edelim
                     let error = NSError(domain: "AppErrorDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Download URL was nil after successful upload"])
                    completion(.failure(error))
                }
            }
        }
    }


    // --- Firestore URL Kaydetme Fonksiyonu (Alert eklendi) ---
    private func saveProfileImageURL(url: URL, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
             let error = NSError(domain: "AppErrorDomain", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            // Hata durumunda alert ayarları
            self.alertTitle = "Error"
            self.alertMessage = error.localizedDescription
            self.showAlert = true
            completion(error)
            return
        }

        let db = Firestore.firestore()
        db.collection("Users").document(userId).updateData([
            "profileImageURL": url.absoluteString
        ]) { error in
            if let error = error {
                 print("Error saving profile image URL to Firestore: \(error.localizedDescription)")
                 // Hata durumunda alert ayarları
                 self.alertTitle = "Database Error"
                 self.alertMessage = "Failed to save profile photo information: \(error.localizedDescription)"
                 self.showAlert = true
                 completion(error)
            } else {
                 print("Profile image URL saved successfully to Firestore!")
                 // Başarı durumunda alert ayarları
                 self.alertTitle = "Success"
                 self.alertMessage = "Profile photo updated successfully!"
                 self.showAlert = true
                 self.isNewImageSelected = false
                 completion(nil)
            }
        }
    }
    // -------------------------------------------------------

    // --- Biyografi Güncelleme Fonksiyonu (Alert zaten vardı) ---
     private func updateBiography() {
         guard let userId = Auth.auth().currentUser?.uid else {
             print("No user logged in")
             self.alertTitle = "Error"
             self.alertMessage = "You must be logged in to update your biography."
             self.showAlert = true
             return
         }

         let db = Firestore.firestore()
         db.collection("Users").document(userId).updateData([
             "biography": bio
         ]) { error in
             if let error = error {
                 print("Error updating biography: \(error.localizedDescription)")
                 self.alertTitle = "Error"
                 self.alertMessage = "Failed to update biography: \(error.localizedDescription)"
                 self.showAlert = true
             } else {
                 print("Biography updated successfully!")
                 self.alertTitle = "Success"
                 self.alertMessage = "Biography updated successfully!"
                 self.showAlert = true
             }
         }
     }
     // -----------------------------------------------------
}


// ImagePicker ve Coordinator (Değişiklik yok)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isNewImageSelected: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.isNewImageSelected = true
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


#Preview {
    ProfileView()
}
