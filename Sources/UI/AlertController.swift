import UIKit

class AlertController: UIAlertController {
    /// A closure called before the alert is dismissed but only if done by own method and not manually
    @objc
    public var willDismissHandler: (() -> Void)?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        willDismissHandler?()
    }
}
