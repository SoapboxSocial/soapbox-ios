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

        let original = view.frame.size.height / 3

        var newBottomOffset = (view.frame.maxY - keyboardFrame.minY) + 20
        if newBottomOffset == 0 {
            newBottomOffset = original
        }

        debugPrint(newBottomOffset)
        debugPrint(original)
        if newBottomOffset <= original {
            return
        }

        bottomLayoutConstraint.constant = -newBottomOffset
        view.layoutIfNeeded()
    }
}
