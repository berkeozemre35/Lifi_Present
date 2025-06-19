import Foundation

struct WeatherDataResponse: Decodable {
    let mainInfo: MainInfo
    let weatherInfo: [WeatherInfo]
    let wind: Wind

    enum CodingKeys: String, CodingKey {
        case mainInfo = "main"
        case weatherInfo = "weather"
        case wind
    }
}

struct MainInfo: Decodable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct WeatherInfo: Decodable {
    let main: String         
    let description: String
}

struct Wind: Decodable {
    let speed: Double
}

class WeatherManager {
    private let apiKey = "5d8d1907e7676d53fea4855982f528c4"

    func fetchWeather(forCity city: String, completion: @escaping (Result<WeatherDataResponse, Error>) -> Void) {
        let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let weatherData = try JSONDecoder().decode(WeatherDataResponse.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
