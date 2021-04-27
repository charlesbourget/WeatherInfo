import SwiftUI

struct SettingsView: View {
    @ObservedObject private var state: AppState
    @State private var apiKey: String
    @State private var isEditing: Bool
    
    init(state: AppState) {
        self.state = state
        self.apiKey = state.apiKey
        self.isEditing = false
    }
    
    var body: some View {
        VStack {
            Text("Set API key")
            TextField("API key",
                      text: $apiKey
            ) { isEditing in
                self.isEditing = isEditing
            }  onCommit: {
                self.state.setAPIKey(apiKey: self.apiKey)
            }
        }.padding()
    }
}
