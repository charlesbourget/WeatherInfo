import Cocoa
import CoreLocation
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    @ObservedObject var state: AppState
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var menuBar: MenuBar!
    let manager = CLLocationManager()

    override init() {
        state = AppState()
    }

    func applicationDidFinishLaunching(_: Notification) {
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        startMySignificantLocationChanges()

        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = statusBarItem.button {
            button.title = "⛅️ -- ℃"
            button.action = #selector(togglePopover(_:))
        }

        if let button = statusBarItem.button {
            menuBar = MenuBar(button: button, state: state)
        }

        let contentView = ContentView(state: state, menuBar: menuBar, apiKey: state.getAPIKey())

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        // Toggle popover on click from menu bar button
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.becomeKey()
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

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation

        menuBar.setLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        alertDialog(alertText: "Error \(error)")
    }
}
