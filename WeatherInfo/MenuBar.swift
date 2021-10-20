import AppKit
import Foundation
import SwiftUI

class MenuBar {
    private var button: NSStatusBarButton
    private var state: AppState

    private var latitude: Double
    private var longitude: Double

    init(button: NSStatusBarButton, state: AppState) {
        self.button = button
        self.state = state
        latitude = 0
        longitude = 0

        // Data is refreshed on location change or each 10 minutes
        let interval: Double = 10 * 60
        let activity = NSBackgroundActivityScheduler(identifier: "com.cbourget.WeatherInfo.contentRefresh")
        activity.repeats = true
        activity.interval = interval
        activity.tolerance = interval / 4
        activity.qualityOfService = .utility
        activity.schedule { (completion: NSBackgroundActivityScheduler.CompletionHandler) in
            DispatchQueue.main.async {
                self.refreshWeatherData(ttl: 0)
            }
            completion(NSBackgroundActivityScheduler.Result.finished)
        }
    }

    func setLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        refreshWeatherData(ttl: 0)
    }

    @objc func refreshWeatherData(ttl: Int8) {
        if latitude == 0, longitude == 0 {
            alertDialog(alertText: "App probably doesn't have location access. Go to System Preferences -> Security & Privacy -> Location Services")
        }
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(state.getAPIKey())&units=metric")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if error != nil {
                if ttl == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 120.0) {
                        self.refreshWeatherData(ttl: 1)
                    }
                }
                // After two tries the error is probably a network error. Nothing we can do but fail silently and wait for next scheduled refresh
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200 ... 299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 404:
                    DispatchQueue.main.async {
                        alertDialog(alertText: "City not found")
                    }
                case 401:
                    DispatchQueue.main.async {
                        alertDialog(alertText: "Authentification problems. API Key is not valid.")
                    }
                default:
                    DispatchQueue.main.async {
                        alertDialog(alertText: "Error with the response, unexpected status code: \(response!)")
                    }
                }

                return
            }

            if let data = data {
                let currentWeather = try! JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.button.title = self.getButtonText(currentWeather: currentWeather)
                    if let country = currentWeather.sys.country {
                        self.state.setCity(city: "\(currentWeather.name), \(country)")
                    } else {
                        self.state.setCity(city: "\(currentWeather.name)")
                    }

                    self.state.updateLastRefresh()
                }
            }
        })

        task.resume()
    }

    func getButtonText(currentWeather: WeatherResponse) -> String {
        let condition: String
        let isNight = checkIsNight(sunrise: currentWeather.sys.sunrise, sunset: currentWeather.sys.sunset)
        switch currentWeather.weather[0].id {
        case 200 ... 299:
            condition = "⛈"
        case 300 ... 399:
            if isNight {
                condition = "🌧"
            } else {
                condition = "🌦"
            }
        case 511:
            condition = "🧊"
        case 500 ... 599:
            condition = "🌧"
        case 600 ... 699:
            condition = "❄️"
        case 700 ... 799:
            condition = "🌫"
        case 800:
            if isNight {
                condition = "🌙"
            } else {
                condition = "☀️"
            }
        case 801 ... 804:
            condition = "☁️"
        default:
            condition = "⛅️"
        }
        return "\(condition) \(Int(currentWeather.main.temp.rounded())) ℃"
    }

    func checkIsNight(sunrise: Int64, sunset: Int64) -> Bool {
        let currentTimestamp = Int64(Date().timeIntervalSince1970)
        return currentTimestamp < sunrise || currentTimestamp > sunset
    }

    struct WeatherResponse: Decodable {
        struct MainData: Decodable {
            let temp: Double
        }

        struct WeatherData: Decodable {
            let id: Int
        }

        struct SysData: Decodable {
            let sunrise: Int64
            let sunset: Int64
            let country: String?
        }

        let main: MainData
        let weather: [WeatherData]
        let sys: SysData
        let name: String
    }
}
