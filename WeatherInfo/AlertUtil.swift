import AppKit
import Foundation

func alertDialog(alertText: String) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString(alertText, comment: "")
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
