import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @ObservedObject var state: AppState
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var menuBar: MenuBar!
    
    override init() {
        // TODO: Load initial city from config or device location
        state = AppState()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let buttonTitle = "⛅️ -- ℃"
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.title = buttonTitle
            button.action = #selector(togglePopover(_:))
        }
        
        if let button = self.statusBarItem.button, let config = readConfig() {
            menuBar = MenuBar(button: button, apiKey: config["ApiKey"]!, state: state)
        }
        
        let contentView = ContentView(state: state, menuBar: menuBar)
        let popover = NSPopover()
        
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        self.popover = popover
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

