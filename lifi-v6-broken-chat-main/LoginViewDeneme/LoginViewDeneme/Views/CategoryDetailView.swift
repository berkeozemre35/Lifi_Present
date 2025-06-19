import SwiftUI

struct CategoryDetailView: View {

    var category: String
    var subcategories: [String] {
        switch category {
        case "Sports 🏅":
            return ["Football ⚽️", "Basketball 🏀", "Volleyball 🏐"]
        case "Art 🎭":
            return ["Painting 🎨", "Sculpture 🗿", "Design 🧑‍🎨"]
        case "Music 🎵":
            return ["Instruments 🎸", "Singing 🎤", "Production 🎧"]
        case "Foreign Languages 🌍":
            return ["English 🇬🇧", "Spanish 🇪🇸", "French 🇫🇷"]
        case "Technology 💻":
            return ["Programming 💻", "AI 🤖", "Cybersecurity 🔐"]
        case "Health & Fitness 🏋️":
            return ["Gym 🏋️", "Yoga 🧘", "Nutrition 🥗"]
        case "Gaming 🎮":
            return ["Mobile 🎮", "Console 🎮", "eSports 🕹"]
        case "Travel & Culture ✈️":
            return ["Countries 🌍", "Traditions 🏛", "Languages 🗣"]
        case "Business & Finance 💼":
            return ["Entrepreneurship 💼", "Investing 📈", "Marketing 📊"]
        case "Movies & TV 🎬":
            return ["Action 🎬", "Comedy 😂", "Sci-Fi 👽"]
        case "Books & Literature 📚":
            return ["Novels 📚", "Philosophy 🧠", "Self-help 🧘"]
        case "Lifestyle 🌿":
            return ["Fashion 👗", "Minimalism 🧺", "Daily Routines ☀️"]
        case "Science 🔬":
            return ["Physics ⚛️", "Biology 🧬", "Astronomy 🔭"]
        default:
            return []
        }
    }

    var body: some View {
        VStack {
            Text(category)
                .font(.largeTitle)
                .padding()

            List(subcategories, id: \.self) { subcategory in
                NavigationLink(destination: SubcategoryDetailView(subcategory: subcategory)) {
                    CategoryRowView(categoryName: subcategory)
                }
            }
        }
    }
}

#Preview {
    CategoryDetailView(category: "Sports 🥇")
}
