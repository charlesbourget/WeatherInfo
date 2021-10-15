import SwiftUI

struct ContentView: View {
    private var menuBar: MenuBar

    @ObservedObject private var state: AppState
    @State private var isEditing = false
    @State private var apiKey = ""

    init(state: AppState, menuBar: MenuBar, apiKey: String) {
        self.state = state
        self.menuBar = menuBar
        self.apiKey = apiKey
    }

    var body: some View {
        VStack {
            HStack {
                Button("Refresh data") {
                    menuBar.refreshWeatherData(ttl: 0)
                }.padding()
                Button("Close app") {
                    NSApplication.shared.terminate(self)
                }.padding()
            }
            Text("Viewing weather for : \(state.getCity().capitalized)")
                .font(.caption)
            Text("Last refresh : \(state.getLastRefresh())")
                .font(.caption)
            VStack {
                Text("Set API Key")
                TextField("API key",
                          text: $apiKey) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    self.state.setAPIKey(apiKey: self.apiKey)
                }
            }.padding()
        }.padding()
    }
}
