import UIKit

extension UIFont {
    class func rounded(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        return rounded(withPointSize: preferredFont(forTextStyle: style).pointSize, weight: weight)
    }

    class func rounded(withPointSize pointSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: pointSize, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }

        return systemFont
    }
}
