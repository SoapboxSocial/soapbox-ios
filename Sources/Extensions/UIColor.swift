import UIKit

extension UIColor {
    static var brandColor: UIColor {
        UIColor(displayP3Red: 133 / 255, green: 90 / 255, blue: 255 / 255, alpha: 1)
    }

    static var lightBrandColor: UIColor {
        UIColor(displayP3Red: 161 / 255, green: 141 / 255, blue: 248 / 255, alpha: 1)
    }

    static var background: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .systemGray6
            }
        }
    }

    static var foreground: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .systemGray6
            } else {
                return .white
            }
        }
    }

    static var twitter: UIColor {
        UIColor(red: 29 / 255, green: 161 / 255, blue: 242 / 255, alpha: 1.0)
    }

    static var exitButtonBackground: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return UIColor.systemRed.withAlphaComponent(0.2)
            } else {
                return UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
    }
}
