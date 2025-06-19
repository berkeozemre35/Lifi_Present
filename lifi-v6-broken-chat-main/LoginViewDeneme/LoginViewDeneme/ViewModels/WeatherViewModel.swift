import Foundation

class WeatherViewModel: ObservableObject {
    @Published var temperature: String = "--"
    @Published var description: String = ""
    @Published var city: String = ""
    @Published var feelsLike: String = "--"
    @Published var humidity: String = "--"
    @Published var windSpeed: String = "--"
    @Published var iconName: String = "cloud.sun.fill" 

    let weatherManager = WeatherManager()

    func loadWeather(for city: String) {
        weatherManager.fetchWeather(forCity: city) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.city = city
                    self.temperature = "\(Int(data.mainInfo.temp))°C"
                    self.feelsLike = "\(Int(data.mainInfo.feels_like))°C"
                    self.humidity = "\(data.mainInfo.humidity)%"
                    self.windSpeed = "\(data.wind.speed) m/s"
                    self.description = data.weatherInfo.first?.description.capitalized ?? ""

                    // 🔥 İkonu dinamik belirle
                    let condition = data.weatherInfo.first?.main.lowercased() ?? ""
                    switch condition {
                    case "clear":
                        self.iconName = "sun.max.fill"
                    case "clouds":
                        self.iconName = "cloud.fill"
                    case "rain":
                        self.iconName = "cloud.rain.fill"
                    case "drizzle":
                        self.iconName = "cloud.drizzle.fill"
                    case "thunderstorm":
                        self.iconName = "cloud.bolt.rain.fill"
                    case "snow":
                        self.iconName = "snow"
                    case "mist", "fog", "haze":
                        self.iconName = "cloud.fog.fill"
                    default:
                        self.iconName = "cloud.sun.fill"
                    }

                case .failure(let error):
                    self.temperature = "--"
                    self.description = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
