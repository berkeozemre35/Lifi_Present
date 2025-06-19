import SwiftUI
import MapKit
import CoreLocation

struct EventAnnotation: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let locationName: String
    let startDate: Date?
    let endDate: Date?
    let createdByName: String?
    let createdBySurname: String?
    let item: EventItem
}

struct MapView: View {
    @State private var selectedTab = "Map"
    @StateObject private var weatherVM = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var eventViewModel = SubcategoryDetailViewModel()

    @State private var selectedEvent: EventItem?

    let tabs = ["Map", "Weather"]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab)
                            .foregroundColor(selectedTab == tab ? .black : .gray)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .font(.title2)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        if selectedTab == "Weather" { Spacer() }
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 2, height: 4)
                            .foregroundColor(.blue)
                        if selectedTab == "Map" { Spacer() }
                    }
                }
            )
            Divider()

            if selectedTab == "Map" {
                GeometryReader { geometry in
                    let annotations: [EventAnnotation] = eventViewModel.items.compactMap { item in
                        if let lat = item.latitude, let lon = item.longitude {
                            return EventAnnotation(
                                title: item.name,
                                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                locationName: item.location ?? "Unknown",
                                startDate: item.startDate,
                                endDate: item.endDate,
                                createdByName: item.createdByName,
                                createdBySurname: item.createdBySurname,
                                item: item
                            )
                        }
                        return nil
                    }

                    Map(
                        coordinateRegion: $locationManager.region,
                        showsUserLocation: true,
                        annotationItems: annotations
                    ) { annotation in
                        MapAnnotation(coordinate: annotation.coordinate) {
                            VStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(annotation.title)
                                        .font(.headline)
                                        .foregroundColor(.black)

                                    if let start = annotation.startDate, let end = annotation.endDate {
                                        Text("⏰ \(formattedDateRange(start: start, end: end))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Text("📍 \(annotation.locationName)")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    if let name = annotation.createdByName, let surname = annotation.createdBySurname {
                                        Text("👤 \(name) \(surname)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }

                                    Button("Detaya Git") {
                                        selectedEvent = annotation.item
                                    }
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)

                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .frame(height: geometry.size.height - 20)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else {
                WeatherView()
            }

            Spacer(minLength: 0)
        }
        .onAppear {
            getCityAndLoadWeather()
            eventViewModel.fetchAllItems()
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(eventItem: event)
        }
    }

    func getCityAndLoadWeather() {
        guard let location = locationManager.userLocation else { return }

        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let city = placemarks?.first?.locality {
                weatherVM.loadWeather(for: city)
            } else {
                print("❌ Şehir alınamadı")
            }
        }
    }

    private func formattedDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

/*
 import SwiftUI
 import MapKit
 import CoreLocation

 struct EventAnnotation: Identifiable {
     let id = UUID()
     let title: String
     let coordinate: CLLocationCoordinate2D
     let locationName: String
     let startDate: Date?
     let endDate: Date?
     let createdByName: String?
     let createdBySurname: String?
 }

 struct MapView: View {
     @State private var selectedTab = "Map"
     @StateObject private var weatherVM = WeatherViewModel()
     @StateObject private var locationManager = LocationManager()
     @StateObject private var eventViewModel = SubcategoryDetailViewModel()

     let tabs = ["Map", "Weather"]

     var body: some View {
         VStack(spacing: 0) {
             HStack(spacing: 0) {
                 ForEach(tabs, id: \.self) { tab in
                     Button(action: {
                         withAnimation {
                             selectedTab = tab
                         }
                     }) {
                         Text(tab)
                             .foregroundColor(selectedTab == tab ? .black : .gray)
                             .fontWeight(selectedTab == tab ? .bold : .regular)
                             .font(.title2)
                             .frame(maxWidth: .infinity, maxHeight: 50)
                     }
                 }
             }
             .overlay(
                 VStack {
                     Spacer()
                     HStack {
                         if selectedTab == "Weather" { Spacer() }
                         Rectangle()
                             .frame(width: UIScreen.main.bounds.width / 2, height: 4)
                             .foregroundColor(.blue)
                         if selectedTab == "Map" { Spacer() }
                     }
                 }
             )
             Divider()

             if selectedTab == "Map" {
                 GeometryReader { geometry in
                     let annotations: [EventAnnotation] = eventViewModel.items.compactMap { item in
                         if let lat = item.latitude, let lon = item.longitude {
                             return EventAnnotation(
                                 title: item.name,
                                 coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                 locationName: item.location ?? "Unknown location",
                                 startDate: item.startDate,
                                 endDate: item.endDate,
                                 createdByName: item.createdByName,
                                 createdBySurname: item.createdBySurname
                             )
                         }
                         return nil
                     }

                     Map(coordinateRegion: $locationManager.region, annotationItems: annotations) { annotation in
                         MapAnnotation(coordinate: annotation.coordinate) {
                             VStack(spacing: 4) {
                                 VStack(alignment: .leading, spacing: 6) {
                                     Text(annotation.title)
                                         .font(.headline)
                                         .foregroundColor(.black)

                                     if let start = annotation.startDate, let end = annotation.endDate {
                                         Text("⏰ \(formattedDateRange(start: start, end: end))")
                                             .font(.caption)
                                             .foregroundColor(.gray)
                                     }

                                     Text("📍 \(annotation.locationName)")
                                         .font(.caption)
                                         .foregroundColor(.gray)

                                     if let name = annotation.createdByName, let surname = annotation.createdBySurname {
                                         Text("👤 \(name) \(surname)")
                                             .font(.caption2)
                                             .foregroundColor(.secondary)
                                     }

                                     Button("Git") {
                                         print("🔗 Git: \(annotation.title)")
                                     }
                                     .font(.caption)
                                     .foregroundColor(.white)
                                     .padding(.horizontal, 12)
                                     .padding(.vertical, 6)
                                     .background(Color.blue)
                                     .cornerRadius(8)
                                 }
                                 .padding(8)
                                 .background(Color.white)
                                 .cornerRadius(12)
                                 .shadow(radius: 4)

                                 Image(systemName: "mappin.circle.fill")
                                     .font(.title)
                                     .foregroundColor(.red)
                             }
                         }
                     }
                     .frame(height: geometry.size.height - 20)
                     .cornerRadius(12)
                     .padding(.horizontal)
                 }
             } else {
                 WeatherView()
             }

             Spacer(minLength: 0)
         }
         .onAppear {
             getCityAndLoadWeather()
             eventViewModel.fetchAllItems()
             DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 print("🔥 Annotations Test Başlıyor")
                 for item in eventViewModel.items {
                     print("📍 \(item.name) - Lat: \(item.latitude ?? 0), Lon: \(item.longitude ?? 0)")
                 }
             }
         }
     }

     func getCityAndLoadWeather() {
         guard let location = locationManager.userLocation else { return }

         let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
         let geocoder = CLGeocoder()
         geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
             if let city = placemarks?.first?.locality {
                 weatherVM.loadWeather(for: city)
             } else {
                 print("❌ Şehir alınamadı")
             }
         }
     }

     private func formattedDateRange(start: Date, end: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .medium
         formatter.timeStyle = .short
         return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
     }
 }
 */
