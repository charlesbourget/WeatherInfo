import Foundation

class AppState: ObservableObject {
    @Published var city: String
    @Published var lastRefresh: String
    @Published var apiKey: String

    init() {
        city = ""
        lastRefresh = ""
        if let apiKey = UserDefaults.standard.string(forKey: "APIKey") {
            self.apiKey = apiKey
        } else {
            apiKey = ""
        }
    }

    func getCity() -> String {
        return city
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
        return lastRefresh
    }

    func setAPIKey(apiKey: String) {
        self.apiKey = apiKey
        UserDefaults.standard.setValue(self.apiKey, forKey: "APIKey")
    }

    func getAPIKey() -> String {
        return apiKey
    }
}
