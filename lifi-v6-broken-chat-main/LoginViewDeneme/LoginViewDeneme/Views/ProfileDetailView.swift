//
//  ProfileDetailView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 19.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct ProfileDetailView: View {
    var userName: String
    var userSurname: String
    @State private var bio: String = "Loading..." // Biyografi state
    @State private var profileImageURL: String? = nil // Profil resmi URL state

    var body: some View {
        VStack(spacing: 20) {
            // Profil Resmi
            if let urlString = profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        .shadow(radius: 5)
                } placeholder: {
                    ProgressView()
                        .frame(width: 120, height: 120)
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("👤")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }

            // Kullanıcı Adı ve Soyadı
            Text("\(userName) \(userSurname)")
                .font(.title)
                .fontWeight(.semibold)

            // Biography Alanı (Salt Okunur)
            VStack(alignment: .leading, spacing: 10) {
                Text("Biography")
                    .font(.headline)
                    .padding(.bottom, 5)

                Text(bio) // Firestore'dan alınan biyografi
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchUserData()
        }
    }

    private func fetchUserData() {
        // Firestore bağlantısı
        let db = Firestore.firestore()
        db.collection("Users")
            .whereField("name", isEqualTo: userName)
            .whereField("surname", isEqualTo: userSurname)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    bio = "Failed to load biography."
                    return
                }

                if let document = snapshot?.documents.first {
                    let data = document.data()
                    bio = data["biography"] as? String ?? "No biography available."
                    profileImageURL = data["profileImageURL"] as? String
                } else {
                    bio = "Biography not found."
                }
            }
    }
}

#Preview {
    ProfileDetailView(userName: "Berke", userSurname: "Ozemre")
}
