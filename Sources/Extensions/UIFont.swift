import UIKit

extension UIFont {
    class func rounded(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let fontSize = preferredFont(forTextStyle: style).pointSize
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: fontSize)
        }

        return systemFont
    }
}
