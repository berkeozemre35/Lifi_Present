import SwiftUI
import CoreLocation
import MapKit

struct SubcategoryDetailView: View {
    var subcategory: String
    @StateObject private var viewModel = SubcategoryDetailViewModel()
    @StateObject private var locationSearchService = LocationSearchService()

    @State private var newItem: String = ""
    @State private var eventStartDate = Date()
    @State private var eventEndDate = Date()
    @State private var eventLocation: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var showSheet: Bool = false
    @State private var showMapPicker: Bool = false
    @State private var locationSelectionError: String? = nil
    @State private var eventDescription: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text(subcategory)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                if viewModel.items.isEmpty {
                    Text("No events available. Add the first one!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            NavigationLink(destination: EventDetailView(eventItem: item)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    Text("Created by: \(item.createdByName ?? "Unknown") \(item.createdBySurname ?? "")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    if let startDate = item.startDate, let endDate = item.endDate {
                                        Text("Event Time: \(formattedDateRange(startDate: startDate, endDate: endDate))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    if let location = item.location {
                                        Text("Location: \(location)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSheet.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                VStack(alignment: .leading) {
                    Text("Add New Event")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    TextField("Enter event name", text: $newItem)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    DatePicker("Start Date & Time", selection: $eventStartDate, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal)

                    DatePicker("End Date & Time", selection: $eventEndDate, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal)

                    TextField("Enter location", text: $locationSearchService.queryFragment)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    List(locationSearchService.searchResults, id: \ .self) { result in
                        VStack(alignment: .leading) {
                            Text(result.title).font(.headline)
                            Text(result.subtitle).font(.subheadline).foregroundColor(.gray)
                        }
                        .onTapGesture {
                            locationSearchService.queryFragment = result.title + " " + result.subtitle
                            fetchCoordinate(for: result)
                        }
                    }
                    .frame(height: 150)

                    Button(action: {
                        showMapPicker = true
                    }) {
                        HStack {
                            Image(systemName: "map")
                            Text("Select from Map")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Text("Description")
                        .font(.headline)
                        .padding(.horizontal)

                    TextEditor(text: $eventDescription)
                        .frame(height: 100)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    if let locationSelectionError = locationSelectionError {
                        Text(locationSelectionError)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    HStack {
                        Button("Cancel") {
                            showSheet = false
                            resetForm()
                        }
                        .padding()

                        Button("Add") {
                            if selectedCoordinate == nil {
                                locationSelectionError = "📍 Please select a location from list or map."
                                return
                            }
                            Task {
                                await viewModel.addItem(
                                    name: newItem,
                                    subcategory: subcategory,
                                    startDate: eventStartDate,
                                    endDate: eventEndDate,
                                    location: locationSearchService.queryFragment,
                                    latitude: selectedCoordinate?.latitude,
                                    longitude: selectedCoordinate?.longitude,
                                    description: eventDescription
                                )
                                showSheet = false
                                resetForm()
                                viewModel.fetchItems(for: subcategory)
                            }
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .sheet(isPresented: $showMapPicker) {
                    MapLocationPickerView(onLocationPicked: { placemark, coordinate in
                        self.locationSearchService.queryFragment = placemark.name ?? "Unknown"
                        self.selectedCoordinate = coordinate
                        self.locationSelectionError = nil
                        self.showMapPicker = false
                    })
                }
            }
            .onAppear {
                viewModel.fetchItems(for: subcategory)
            }
        }
    }

    private func resetForm() {
        newItem = ""
        eventStartDate = Date()
        eventEndDate = Date()
        locationSearchService.queryFragment = ""
        selectedCoordinate = nil
        locationSelectionError = nil
        eventDescription = ""
    }

    private func formattedDateRange(startDate: Date, endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    private func fetchCoordinate(for completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.selectedCoordinate = coordinate
                self.eventLocation = completion.title + " " + completion.subtitle
                self.locationSelectionError = nil
            }
        }
    }
}
