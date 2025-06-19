import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SubcategoryDetailViewModel: ObservableObject {
    @Published var items: [EventItem] = []
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    func fetchItems(for subcategory: String) {
        db.collection("items")
            .whereField("subcategory", isEqualTo: subcategory)
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error fetching items: \(error.localizedDescription)"
                    }
                    return
                }

                if let documents = snapshot?.documents {
                    let fetchedItems = documents.map { document in
                        let data = document.data()
                        return EventItem(
                            id: document.documentID,
                            name: data["name"] as? String ?? "Unknown",
                            createdBy: data["createdBy"] as? String,
                            createdByName: data["createdByName"] as? String,
                            createdBySurname: data["createdBySurname"] as? String,
                            startDate: (data["startDate"] as? Timestamp)?.dateValue(),
                            endDate: (data["endDate"] as? Timestamp)?.dateValue(),
                            location: data["location"] as? String ?? "Unknown Location",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                            latitude: data["latitude"] as? Double,
                            longitude: data["longitude"] as? Double,
                            description: data["description"] as? String
                        )
                    }
                    DispatchQueue.main.async {
                        self.items = fetchedItems
                    }
                }
            }
    }

    func fetchAllItems() {
        db.collection("items")
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error fetching items: \(error.localizedDescription)"
                    }
                    return
                }

                if let documents = snapshot?.documents {
                    let fetchedItems = documents.map { document in
                        let data = document.data()
                        return EventItem(
                            id: document.documentID,
                            name: data["name"] as? String ?? "Unknown",
                            createdBy: data["createdBy"] as? String,
                            createdByName: data["createdByName"] as? String,
                            createdBySurname: data["createdBySurname"] as? String,
                            startDate: (data["startDate"] as? Timestamp)?.dateValue(),
                            endDate: (data["endDate"] as? Timestamp)?.dateValue(),
                            location: data["location"] as? String ?? "Unknown Location",
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                            latitude: data["latitude"] as? Double,
                            longitude: data["longitude"] as? Double,
                            description: data["description"] as? String
                        )
                    }
                    DispatchQueue.main.async {
                        self.items = fetchedItems
                    }
                }
            }
    }

    func addItem(
        name: String,
        subcategory: String,
        startDate: Date,
        endDate: Date,
        location: String,
        latitude: Double?,
        longitude: Double?,
        description: String
    ) async {
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in."
            }
            return
        }

        let userId = user.uid
        let userRef = db.collection("Users").document(userId)

        do {
            let userDoc = try await userRef.getDocument()
            let userData = userDoc.data() ?? [:]
            let userName = userData["name"] as? String ?? "Unknown User"
            let userSurname = userData["surname"] as? String ?? "Unknown Surname"

            let newEvent = [
                "name": name,
                "subcategory": subcategory,
                "createdBy": userId,
                "createdByName": userName,
                "createdBySurname": userSurname,
                "startDate": Timestamp(date: startDate),
                "endDate": Timestamp(date: endDate),
                "location": location,
                "latitude": latitude as Any,
                "longitude": longitude as Any,
                "createdAt": Timestamp(date: Date()),
                "description": description
            ] as [String: Any]

            try await db.collection("items").addDocument(data: newEvent)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error adding item: \(error.localizedDescription)"
            }
        }
    }
}
