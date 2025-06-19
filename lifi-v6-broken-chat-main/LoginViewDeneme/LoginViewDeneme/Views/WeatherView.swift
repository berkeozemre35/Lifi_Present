import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherVM = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var animateIcon = false

    var body: some View {
        ZStack {
            backgroundGradient(for: weatherVM.iconName)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // 🔹 Şehir + Hava açıklaması + animasyonlu ikon
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(weatherVM.city)
                                .font(.largeTitle)
                                .bold()
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.5), value: weatherVM.city)

                            Text(weatherVM.description)
                                .font(.title3)
                                .foregroundColor(.gray)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.5), value: weatherVM.description)
                        }

                        Spacer()

                        Image(systemName: weatherVM.iconName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.orange)
                            .rotationEffect(.degrees(animateIcon ? 10 : -10))
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateIcon)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .shadow(radius: 4)
                    )

                    // 🔹 Bilgi Kartları (yumuşak geçişli)
                    VStack(spacing: 12) {
                        InfoCard(title: "Temperature", value: weatherVM.temperature)
                        InfoCard(title: "Feels Like", value: weatherVM.feelsLike)
                        InfoCard(title: "Humidity", value: weatherVM.humidity)
                        InfoCard(title: "Wind", value: weatherVM.windSpeed)
                    }
                    .padding(.horizontal)
                    .transition(.slide)
                }
                .padding()
            }
        }
        .onAppear {
            animateIcon = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let location = locationManager.userLocation {
                    let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                        if let city = placemarks?.first?.locality {
                            weatherVM.loadWeather(for: city)
                        } else {
                            print("❌ Şehir alınamadı")
                        }
                    }
                } else {
                    print("⚠️ Konum henüz alınamadı")
                }
            }
        }
    }

    // 🔹 Dinamik arka plan fonksiyonu
    func backgroundGradient(for icon: String) -> LinearGradient {
        switch icon {
        case "sun.max.fill":
            return LinearGradient(colors: [.blue.opacity(0.3), .white], startPoint: .top, endPoint: .bottom)
        case "cloud.fill", "cloud.sun.fill":
            return LinearGradient(colors: [.gray.opacity(0.3), .white], startPoint: .top, endPoint: .bottom)
        case "cloud.rain.fill", "cloud.bolt.rain.fill":
            return LinearGradient(colors: [.blue.opacity(0.5), .gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case "snow":
            return LinearGradient(colors: [.blue.opacity(0.6), .white], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.blue.opacity(0.2), .white], startPoint: .top, endPoint: .bottom)
        }
    }
}

// 🔹 Kart component'i
struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .bold()
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .shadow(radius: 2)
    }
}

#Preview {
    WeatherView()
}
