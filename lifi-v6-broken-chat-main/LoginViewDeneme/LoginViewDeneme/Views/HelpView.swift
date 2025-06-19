import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .padding(.top, 50)
            
            Text("Need Help?")
                .font(.title)
                .fontWeight(.bold)

            Text("Tap the button below to visit our support website.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                if let url = URL(string: "https://berkeozemre35.github.io/lifi-website/") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Go to Support Site")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Help")
    }
}


