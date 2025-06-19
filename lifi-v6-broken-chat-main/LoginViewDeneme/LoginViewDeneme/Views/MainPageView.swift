import SwiftUI

struct MainPageView: View {
    var categories = [
        "Sports 🏅",
        "Art 🎭",
        "Music 🎵",
        "Foreign Languages 🌍",
        "Technology 💻",
        "Health & Fitness 🏋️",
        "Travel & Culture ✈️",
        "Gaming 🎮",
        "Science 🔬",
        "Business & Finance 💼",
        "Movies & TV 🎬",
        "Books & Literature 📚",
        "Lifestyle 🌿"
    ]

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // 🔹 Kategorileri listele
                    Section {
                        ForEach(categories, id: \.self) { category in
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                CategoryRowView(categoryName: category)
                            }
                        }
                    } header: {
                        // 🔹 Başlıkla liste arasında küçük boşluk
                        Text(" ")
                            .padding(.top, 2) // daha az boşluk
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Categories")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    MainPageView()
}

