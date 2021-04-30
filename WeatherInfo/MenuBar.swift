import Foundation
import SwiftUI
import AppKit

class MenuBar {
    
    private var button: NSStatusBarButton
    private var state: AppState
    
    private var latitude: Double
    private var longitude: Double
    
    init (button: NSStatusBarButton, state: AppState) {
        self.button = button
        self.state = state
        latitude = 0
        longitude = 0
        
        // Data is refreshed on location change or each 20 minutes
        let interval = 1200.0
        Timer.scheduledTimer(timeInterval: interval, target: self,  selector: #selector(refreshWeatherData), userInfo: nil, repeats: true)
    }
    
    func setLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        refreshWeatherData()
    }
    
    @objc func refreshWeatherData() {
        if (latitude == 0 && longitude == 0) {
            alertDialog(alertText: "App probably doesn't have location access. Go to System Preferences -> Security & Privacy -> Location Services")
        }
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(state.getAPIKey())&units=metric")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching weather from API: \(error)")
                self.refreshWeatherData()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.alertDialog(alertText: "City not found")
                    }
                } else {
                    print("Error with the response, unexpected status code: \(response!)")
                }
                return
            }
            
            if let data = data{
                let currentWeather = try! JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateButton(currentWeather: currentWeather)
                    self.state.setCity(city: "\(currentWeather.name), \(currentWeather.sys.country ?? "")")
                    self.state.updateLastRefresh()
                }
            }
        })
        
        task.resume()
    }
    
    func updateButton(currentWeather: WeatherResponse) {
        let condition: String
        let isNight = checkIsNight(sunrise: currentWeather.sys.sunrise, sunset: currentWeather.sys.sunset);
        switch currentWeather.weather[0].id {
        case (200...299):
            condition = "⛈"
            break
        case (300...399):
            if (isNight) {
                condition = "🌧"
            } else {
                condition = "🌦"
            }
            break
        case 511:
            condition = "🧊"
            break
        case (500...599):
            condition = "🌧"
            break
        case (600...699):
            condition = "❄️"
            break
        case (700...799):
            condition = "🌫"
            break
        case 800:
            if (isNight) {
                condition = "🌙"
            } else {
                condition = "☀️"
            }
            break
        case (801...804):
            condition = "☁️"
            break
        default:
            condition = "⛅️"
        }
        button.title  = "\(condition) \(currentWeather.main.temp) ℃"
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
    
    func alertDialog(alertText: String){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString(alertText, comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}
