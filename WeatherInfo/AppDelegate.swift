import Cocoa
import SwiftUI
import CoreLocation

@main
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    
    @ObservedObject var state: AppState
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var menuBar: MenuBar!
    let manager = CLLocationManager()
    
    override init() {
        // TODO: Load initial city from config or device location
        state = AppState()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        startMySignificantLocationChanges()
        
        let buttonTitle = "⛅️ -- ℃"
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.title = buttonTitle
            button.action = #selector(togglePopover(_:))
        }
        
        if let button = self.statusBarItem.button {
            menuBar = MenuBar(button: button, state: state)
        }
        
        let contentView = ContentView(state: state, menuBar: menuBar, apiKey: state.getAPIKey())
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
    
    func startMySignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The device does not support this service.
            return
        }
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        menuBar.setLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
    }
    
}

