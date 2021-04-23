import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var apiKey: String!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let buttonTitle = "⛅️ -- ℃"
        
        let contentView = ContentView()
        let popover = NSPopover()
        
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.title = buttonTitle
            button.action = #selector(togglePopover(_:))
        }
        
        if let config = readConfig() {
            self.apiKey = config["ApiKey"]
        }
        
        // Force initial fetch of weather and then fetch each 20min
        refreshWeatherData()
        let interval = 1200.0
        Timer.scheduledTimer(timeInterval: interval, target: self,  selector: #selector(refreshWeatherData), userInfo: nil, repeats: true)
        
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func updateButton(currentWeather: WeatherResponse) {
        if let button = self.statusBarItem.button {
            let condition: String
            switch currentWeather.weather[0].id {
            case (200...299):
                condition = "⛈"
                break
            case (300...399):
                condition = "🌦"
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
                condition = "☀️"
                break
            case (801...804):
                condition = "☁️"
                break
            default:
                condition = "⛅️"
            }
            button.title  = "\(condition) \(currentWeather.main.temp) ℃"
        }
        
    }
    
    @objc func refreshWeatherData() {
        let city = "montreal"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(self.apiKey!)&units=metric")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching weather from API: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response!)")
                return
            }
            
            if let data = data{
                let currentWeather = try? JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateButton(currentWeather: currentWeather!)
                }
            }
        })
        
        task.resume()
    }

    struct WeatherResponse: Decodable {
        struct MainData: Decodable {
            let temp: Double
        }
        
        struct WeatherData: Decodable {
            let id: Int
        }
        
        let main: MainData
        let weather: [WeatherData]
    }
    
    func readConfig() -> Dictionary<String, String>? {
        var configDict: Dictionary<String, String>?
        if  let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, String> {
                configDict = dict
            }
        }
        
        return configDict
    }

}

