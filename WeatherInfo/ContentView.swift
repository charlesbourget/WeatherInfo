import SwiftUI

struct ContentView: View {
    private var menuBar: MenuBar
    @State private var window: NSWindow!
    
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
            Button("Settings") {
                toggleSettingsView()
            }
        }.padding()
    }
    
    func toggleSettingsView() {
        if window == nil {
            let settingsView = SettingsView(state: state)
            window = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            window.center()
            window.contentView = NSHostingView(rootView: settingsView)
        }
        window.makeKeyAndOrderFront(nil)
    }
}
