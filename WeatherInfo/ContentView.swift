import SwiftUI

struct ContentView: View {
    private var menuBar: MenuBar
    @ObservedObject private var state: AppState
    @State private var isEditing = false
    
    init(state: AppState, menuBar: MenuBar) {
        self.state = state
        self.menuBar = menuBar
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Refresh data") {
                    menuBar.refreshWeatherData()
                }.padding()
                Button("Close app") {
                    NSApplication.shared.terminate(self)
                }.padding()
            }
            Text("Viewing weather for : \(state.getCity().capitalized)")
                .font(.caption)
            Text("Last refresh : \(state.getLastRefresh())")
                .font(.caption)
        }.padding()
    }
}
