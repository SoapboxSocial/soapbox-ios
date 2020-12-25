import Foundation

import UIKit

extension UIAlertController {
    class func confirmation(onAccepted: (() -> Void)?, onDeclined: (() -> Void)? = nil, message: String? = nil) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("are_you_sure", comment: ""), message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: { _ in
            onDeclined?()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
            onAccepted?()
        }))

        return alert
    }
}
