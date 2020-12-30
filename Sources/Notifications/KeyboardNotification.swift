import UIKit

public struct KeyboardNotification {
    let notification: NSNotification
    let userInfo: NSDictionary

    /// Initializer
    ///
    /// :param: notification Keyboard-related notification
    public init(_ notification: NSNotification) {
        self.notification = notification
        if let userInfo = notification.userInfo {
            self.userInfo = userInfo as NSDictionary
        } else {
            userInfo = NSDictionary()
        }
    }

    /// Start frame of the keyboard in screen coordinates
    public var screenFrameBegin: CGRect {
        if let value = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            return value.cgRectValue
        }

        return .zero
    }

    /// End frame of the keyboard in screen coordinates
    public var screenFrameEnd: CGRect {
        if let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return value.cgRectValue
        }

        return .zero
    }

    /// Start frame of the keyboard in coordinates of specified view
    ///
    /// :param: view UIView to whose coordinate system the frame will be converted
    /// :returns: frame rectangle in view's coordinate system
    public func frameBeginForView(view: UIView) -> CGRect {
        return view.convert(screenFrameBegin, from: view.window)
    }

    /// End frame of the keyboard in coordinates of specified view
    ///
    /// :param: view UIView to whose coordinate system the frame will be converted
    /// :returns: frame rectangle in view's coordinate system
    public func frameEndForView(view: UIView) -> CGRect {
        return view.convert(screenFrameEnd, from: view.window)
    }
}
