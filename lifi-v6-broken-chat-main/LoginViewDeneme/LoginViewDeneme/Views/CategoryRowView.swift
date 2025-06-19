import SwiftUI

struct CategoryRowView: View {
    var categoryName: String = "Example"

    var body: some View {
        HStack {
            Text(categoryName)
                .font(.title2) // 🆙 büyütüldü
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.vertical, 10) // 🆙 dikey padding artırıldı
    }
}

#Preview {
    CategoryRowView(categoryName: "Science 🔬")
}
