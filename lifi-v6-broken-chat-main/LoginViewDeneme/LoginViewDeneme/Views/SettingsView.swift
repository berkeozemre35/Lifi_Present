import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var selectedLanguage: String = "English"
    @Environment(\.dismiss) var dismiss

    var languageOptions: [String] {
        selectedLanguage == "English" ? ["English", "Turkish"] : ["İngilizce", "Türkçe"]
    }

    var body: some View {
        NavigationView {
            List {
                // Dil Seçimi
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                    Picker(selectedLanguage == "English" ? "Language" : "Dil", selection: $selectedLanguage) {
                        ForEach(languageOptions, id: \.self) { language in
                            Text(language)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.vertical, 8)

                // Uygulamaya Puan Ver
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 24))
                        Text(selectedLanguage == "English" ? "Rate the App" : "Uygulamayı Puanla")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                }

                // Yardım
                NavigationLink(destination: HelpView()) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                        Text(selectedLanguage == "English" ? "Help" : "Yardım")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                }

                // App Statistics
                NavigationLink(destination: StatsView()) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                        Text(selectedLanguage == "English" ? "App Statistics" : "Uygulama İstatistikleri")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                }

                // Çıkış Yap
                Button(action: logOut) {
                    HStack {
                        Image(systemName: "arrow.backward.square")
                            .foregroundColor(.red)
                            .font(.system(size: 24))
                        Text(selectedLanguage == "English" ? "Log Out" : "Çıkış Yap")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.grouped)
        }
    }

    private func logOut() {
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
