import Foundation

class AppState: ObservableObject {
    @Published var city: String
    @Published var lastRefresh: String
    
    init() {
        if let setCity = UserDefaults.standard.string(forKey: "City") {
            self.city = setCity
        } else {
            self.city = "montreal"
        }
        lastRefresh = ""
    }
    
    func getCity() -> String {
        return self.city
    }
    
    func setCity(city: String) {
        self.city = city
        UserDefaults.standard.setValue(self.city, forKey: "City")
    }
    
    func updateLastRefresh() {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        lastRefresh = formatter.string(from: currentDateTime)
    }
    
    func getLastRefresh() -> String {
        return self.lastRefresh
    }
}
