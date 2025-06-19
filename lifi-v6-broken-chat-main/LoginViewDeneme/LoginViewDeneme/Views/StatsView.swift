import SwiftUI
import FirebaseFirestore

struct StatsView: View {
    @State private var userCount: Int = 0
    @State private var eventCount: Int = 0
    @State private var topCategories: [(String, Int)] = []
    @State private var mostJoinedEvents: [(String, Int)] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("📊 App Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("👥 Total Users: \(userCount)")
                .font(.title2)

            Text("📅 Total Events: \(eventCount)")
                .font(.title2)

            Divider()

            VStack(alignment: .leading) {
                Text("🏆 Top 3 Categories:")
                    .font(.headline)

                if topCategories.isEmpty {
                    Text("No data available")
                        .foregroundColor(.gray)
                } else {
                    ForEach(topCategories.prefix(3), id: \.0) { category, count in
                        Text("• \(category): \(count)")
                    }
                }
            }

            Divider()

            VStack(alignment: .leading) {
                Text("🔥 Most Joined Events:")
                    .font(.headline)

                if mostJoinedEvents.isEmpty {
                    Text("No data available")
                        .foregroundColor(.gray)
                } else {
                    ForEach(mostJoinedEvents, id: \.0) { eventName, count in
                        Text("• \(eventName): \(count) participants")
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            fetchUserCount()
            fetchEventCount()
            fetchTopCategories()
            fetchMostJoinedEvents()
        }
    }

    func fetchUserCount() {
        Firestore.firestore().collection("Users").getDocuments { snapshot, _ in
            self.userCount = snapshot?.documents.count ?? 0
        }
    }

    func fetchEventCount() {
        Firestore.firestore().collection("items").getDocuments { snapshot, _ in
            self.eventCount = snapshot?.documents.count ?? 0
        }
    }

    func fetchTopCategories() {
        Firestore.firestore().collection("items").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            var categoryCount: [String: Int] = [:]

            for doc in docs {
                if let category = doc.data()["subcategory"] as? String {
                    categoryCount[category, default: 0] += 1
                }
            }

            self.topCategories = categoryCount.sorted { $0.value > $1.value }
        }
    }

    func fetchMostJoinedEvents() {
        let db = Firestore.firestore()

        // Step 1: Count Accepted Requests per eventID
        db.collection("Requests")
            .whereField("status", isEqualTo: "Accepted")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                var eventCounts: [String: Int] = [:]

                for doc in documents {
                    if let eventID = doc.data()["eventID"] as? String {
                        eventCounts[eventID, default: 0] += 1
                    }
                }

                // Step 2: Sort top 3
                let topEvents = eventCounts.sorted { $0.value > $1.value }.prefix(3)

                // Step 3: Fetch event names from "items"
                var results: [(String, Int)] = []
                let group = DispatchGroup()

                for (eventID, count) in topEvents {
                    group.enter()
                    db.collection("items").document(eventID).getDocument { snap, _ in
                        let name = snap?.data()?["name"] as? String ?? "Unknown Event"
                        results.append((name, count))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.mostJoinedEvents = results
                }
            }
    }
}
