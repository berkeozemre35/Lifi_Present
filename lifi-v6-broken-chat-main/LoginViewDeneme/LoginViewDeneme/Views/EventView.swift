import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EventView: View {
    @State private var selectedSegment: Segment = .event // Default segment
    @StateObject private var requestsViewModel = RequestsViewModel() // Add the view model

    enum Segment {
        case event, requests
    }

    var body: some View {
        VStack(spacing: 0) {
            // Segment Control
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        selectedSegment = .event
                    }
                }) {
                    Text("Event")
                        .foregroundColor(selectedSegment == .event ? .black : .gray)
                        .fontWeight(selectedSegment == .event ? .bold : .regular)
                        .font(.title2)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                }

                Button(action: {
                    withAnimation {
                        selectedSegment = .requests
                    }
                }) {
                    Text("Requests")
                        .foregroundColor(selectedSegment == .requests ? .black : .gray)
                        .fontWeight(selectedSegment == .requests ? .bold : .regular)
                        .font(.title2)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        if selectedSegment == .requests { Spacer() }
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 2, height: 4)
                            .foregroundColor(.blue)
                        if selectedSegment == .event { Spacer() }
                    }
                }
            )
            Divider()

            if selectedSegment == .event {
                if let userId = Auth.auth().currentUser?.uid {
                    EventContentView(userId: userId) // Pass userId to EventContentView
                } else {
                    Text("Please log in to view events.")
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                RequestsContentView(viewModel: requestsViewModel) // Show requests view
            }

            Spacer()
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EventView()
}
