import UIKit

class ViewControllerWithKeyboardConstraint: UIViewController {
    var bottomLayoutConstraint: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrameNotification),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillChangeFrameNotification(notification: NSNotification) {
        let notification = KeyboardNotification(notification)
        let keyboardFrame = notification.frameEndForView(view: view)

        var newBottomOffset = view.frame.maxY - keyboardFrame.minY
        if newBottomOffset == 0 {
            newBottomOffset = view.frame.size.height / 4
        }

        bottomLayoutConstraint.constant = -(newBottomOffset + 20)
        view.layoutIfNeeded()
    }
}
