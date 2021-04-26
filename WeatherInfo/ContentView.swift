import SwiftUI

struct ContentView: View {
    private var menuBar: MenuBar
    @ObservedObject private var state: AppState
    @State private var city = ""
    @State private var isEditing = false
    
    init(state: AppState, menuBar: MenuBar) {
        self.state = state
        self.menuBar = menuBar
        self.city = state.getCity()
    }
    
    var body: some View {
        TextField(
                "City",
                 text: $city
            ) { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                self.state.setCity(city: city)
                menuBar.refreshWeatherData()
            }
            .disableAutocorrection(true)
        Text("\(state.getCity())")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
