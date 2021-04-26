import Foundation

class AppState: ObservableObject {
    @Published var city: String
    
    init(city: String) {
        self.city = city
    }
    
    func getCity() -> String {
        return self.city
    }
    
    func setCity(city: String) {
        self.city = city
    }
}
