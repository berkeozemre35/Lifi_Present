import SwiftUI
import MapKit

struct MapLocationPickerView: View {
    @Environment(\.dismiss) var dismiss

    var onLocationPicked: (CLPlacemark, CLLocationCoordinate2D) -> Void

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.4237, longitude: 27.1428),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var pickedPlacemark: CLPlacemark?
    @State private var pickedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: annotationList) { annotation in
                MapPin(coordinate: annotation.coordinate, tint: .red)
            }
            .gesture(
                TapGesture().onEnded {
                    let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                        if let placemark = placemarks?.first {
                            pickedPlacemark = placemark
                            pickedCoordinate = region.center
                        }
                    }
                }
            )

            VStack {
                Spacer()
                if pickedCoordinate != nil && pickedPlacemark != nil {
                    Button("Konumu Seç") {
                        onLocationPicked(pickedPlacemark!, pickedCoordinate!)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
            }
        }
    }

    private var annotationList: [Annotation] {
        if let coord = pickedCoordinate {
            return [Annotation(coordinate: coord)]
        }
        return []
    }

    struct Annotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}
