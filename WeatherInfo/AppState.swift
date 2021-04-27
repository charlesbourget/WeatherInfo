import Foundation

class AppState: ObservableObject {
    @Published var city: String
    @Published var lastRefresh: String
    
    init(city: String) {
        self.city = city
        lastRefresh = ""
    }
    
    func getCity() -> String {
        return self.city
    }
    
    func setCity(city: String) {
        self.city = city
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
