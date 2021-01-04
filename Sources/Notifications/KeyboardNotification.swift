import UIKit

public struct KeyboardNotification {
    private let userInfo: NSDictionary

    /// Initializer
    ///
    /// :param: notification Keyboard-related notification
    public init(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            self.userInfo = userInfo as NSDictionary
        } else {
            userInfo = NSDictionary()
        }
    }

    /// End frame of the keyboard in screen coordinates
    public var screenFrameEnd: CGRect {
        if let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return value.cgRectValue
        }

        return .zero
    }

    /// End frame of the keyboard in coordinates of specified view
    ///
    /// :param: view UIView to whose coordinate system the frame will be converted
    /// :returns: frame rectangle in view's coordinate system
    public func frameEndForView(view: UIView) -> CGRect {
        return view.convert(screenFrameEnd, from: view.window)
    }
}
