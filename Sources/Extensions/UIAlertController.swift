import Foundation

import UIKit

extension UIAlertController {
    class func confirmation(
        onAccepted: (() -> Void)?,
        onDeclined: (() -> Void)? = nil,
        message: String? = nil,
        confirm: String? = nil,
        decline: String? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("are_you_sure", comment: ""), message: message, preferredStyle: .alert)

        var no = NSLocalizedString("no", comment: "")
        if decline != nil {
            no = decline!
        }

        alert.addAction(UIAlertAction(title: no, style: .default, handler: { _ in
            onDeclined?()
        }))

        var yes = NSLocalizedString("yes", comment: "")
        if decline != nil {
            yes = confirm!
        }

        alert.addAction(UIAlertAction(title: yes, style: .destructive, handler: { _ in
            onAccepted?()
        }))

        return alert
    }
}
