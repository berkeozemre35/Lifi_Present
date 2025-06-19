import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct EventDetailView: View {

    var eventItem: EventItem
    @State private var showRequestButton: Bool = false
    @State private var profileImageURL: String? = nil
    @State private var showRequestAlert: Bool = false
    @State private var requestAlertMessage: String = ""
    @State private var participantCount: Int = 0
    @State private var distanceToEvent: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Profil Resmi ve Kullanıcı Bilgileri
            HStack(spacing: 15) {
                NavigationLink(destination: ProfileDetailView(userName: eventItem.createdByName ?? "Unknown", userSurname: eventItem.createdBySurname ?? "")) {
                    if let urlString = profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    .shadow(radius: 5)
                            case .failure:
                                defaultProfileIcon()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        defaultProfileIcon()
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let createdByName = eventItem.createdByName, let createdBySurname = eventItem.createdBySurname, !createdByName.isEmpty || !createdBySurname.isEmpty {
                        Text("\(createdByName) \(createdBySurname)".trimmingCharacters(in: .whitespaces))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    } else {
                        Text("Unknown Creator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }

            Text(eventItem.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 10)

            if let startDate = eventItem.startDate, let endDate = eventItem.endDate {
                HStack {
                    Image(systemName: "calendar")
                    Text("\(startDate.formatted(date: .abbreviated, time: .shortened)) - \(endDate.formatted(date: .abbreviated, time: .shortened))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            if let location = eventItem.location, !location.isEmpty {
                HStack {
                    Image(systemName: "location.fill")
                    Text(location)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            if let distance = distanceToEvent {
                HStack {
                    Image(systemName: "location.circle")
                    Text(String(format: "Uzaklık: %.2f km", distance))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            if let description = eventItem.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.headline)
                    Text(description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
                .padding(.top)
            }

            Text("Katılan kişi sayısı: \(participantCount)")
                .font(.subheadline)
                .foregroundColor(.blue)

            if showRequestButton {
                Button(action: sendJoinRequest) {
                    Text("Request to Join")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.vertical)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchProfileImageURL()
            checkIfUserCanRequest()
            fetchParticipantCount()
            calculateDistanceToEvent()
        }
        .alert("Join Request", isPresented: $showRequestAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(requestAlertMessage)
        }
    }

    @ViewBuilder
    private func defaultProfileIcon() -> some View {
        Circle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            )
            .shadow(radius: 5)
    }

    private func fetchProfileImageURL() {
        guard let creatorId = eventItem.createdBy else { return }
        let db = Firestore.firestore()
        db.collection("Users").document(creatorId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image URL: \(error.localizedDescription)")
                self.profileImageURL = nil
                return
            }
            if let data = snapshot?.data(), let url = data["profileImageURL"] as? String {
                self.profileImageURL = url
            } else {
                self.profileImageURL = nil
            }
        }
    }

    private func checkIfUserCanRequest() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            showRequestButton = false
            return
        }
        showRequestButton = currentUserUID != eventItem.createdBy
    }

    private func sendJoinRequest() {
        let db = Firestore.firestore()
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            self.requestAlertMessage = "You need to be logged in to send a request."
            self.showRequestAlert = true
            return
        }
        guard let eventCreatorUID = eventItem.createdBy else {
            self.requestAlertMessage = "Event creator information is missing. Cannot send request."
            self.showRequestAlert = true
            return
        }
        let eventID = eventItem.id
        guard !eventID.isEmpty else {
            self.requestAlertMessage = "Invalid event information (ID is empty)."
            self.showRequestAlert = true
            return
        }
        guard currentUserUID != eventCreatorUID else {
            self.requestAlertMessage = "You cannot send a join request to your own event."
            self.showRequestAlert = true
            return
        }

        let requestData: [String: Any] = [
            "fromUserUID": currentUserUID,
            "toUserUID": eventCreatorUID,
            "eventID": eventID,
            "eventName": eventItem.name,
            "status": "Pending",
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("Requests").addDocument(data: requestData) { error in
            if let error = error {
                self.requestAlertMessage = "Failed to send join request. Please try again. (\(error.localizedDescription))"
            } else {
                self.requestAlertMessage = "Join request sent successfully!"
            }
            self.showRequestAlert = true
        }
    }

    private func fetchParticipantCount() {
        let db = Firestore.firestore()
        db.collection("Requests")
            .whereField("eventID", isEqualTo: eventItem.id)
            .whereField("status", isEqualTo: "Accepted")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.participantCount = documents.count
                } else {
                    self.participantCount = 0
                }
            }
    }

    private func calculateDistanceToEvent() {
        guard let userLocation = CLLocationManager().location else {
            print("⚠️ Kullanıcı konumu alınamadı.")
            return
        }

        guard let eventLat = eventItem.latitude, let eventLon = eventItem.longitude else {
            print("⚠️ Etkinlik koordinatları eksik.")
            return
        }

        let eventLocation = CLLocation(latitude: eventLat, longitude: eventLon)
        let distanceInMeters = userLocation.distance(from: eventLocation)
        self.distanceToEvent = distanceInMeters / 1000 // km
    }
}

