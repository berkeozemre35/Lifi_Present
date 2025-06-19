import Foundation
import FirebaseFirestore

class EventContentViewModel: ObservableObject {
    @Published var events: [EventItem] = []
    @Published var errorMessage: String = ""
    private let db = Firestore.firestore()

    func fetchEvents(for userId: String) {
        print("Calling fetchEvents for userId: \(userId)")
        db.collection("items")
            .whereField("createdBy", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching events: \(error.localizedDescription)")
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found for userId: \(userId)")
                    self?.errorMessage = "No events found."
                    return
                }
                
                print("Fetched \(documents.count) events for userId: \(userId)")
                for doc in documents {
                    print("Document data: \(doc.data())")
                }
                
                self?.events = documents.compactMap { doc in
                    let data = doc.data()
                    return EventItem(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "No Name",
                        createdBy: data["createdBy"] as? String ?? "Unknown UID", // Varsayılan değer
                        createdBySurname: data["createdBySurname"] as? String ?? "Unknown Surname", // Varsayılan değer
                        startDate: (data["startDate"] as? Timestamp)?.dateValue(),
                        endDate: (data["endDate"] as? Timestamp)?.dateValue(),
                        location: data["location"] as? String ?? "Unknown Location",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue()
                    )
                }
            } 
        
        
    }
    
    func deleteEvent(at offsets: IndexSet) {
            offsets.forEach { index in
                let event = events[index]
                db.collection("items").document(event.id).delete { error in
                    if let error = error {
                        print("Failed to delete event: \(error.localizedDescription)")
                    } else {
                        print("Event \(event.id) deleted successfully.")
                    }
                }
            }
            events.remove(atOffsets: offsets)
        }
    
    func updateEvent(_ event: EventItem) {
            db.collection("items").document(event.id).setData([
                "name": event.name,
                "location": event.location ?? "",
                "startDate": event.startDate != nil ? Timestamp(date: event.startDate!) : NSNull(),
                "endDate": event.endDate != nil ? Timestamp(date: event.endDate!) : NSNull()
            ], merge: true) { error in
                if let error = error {
                    print("Failed to update event: \(error.localizedDescription)")
                } else {
                    print("Event \(event.id) updated successfully.")
                }
            }
        }
    
}

// Günceldir 
