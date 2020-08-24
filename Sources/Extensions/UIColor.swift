import UIKit

extension UIColor {
    static var highlight: UIColor {
        UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)
    }

    static var secondaryBackground: UIColor {
        UIColor(red: 133 / 255, green: 90 / 255, blue: 255 / 255, alpha: 1)
    }

    static var background: UIColor {
        UIColor(red: 236 / 255, green: 239 / 255, blue: 253 / 255, alpha: 1)

//            (UITraitCollection: UITraitCollection) -> UIColor in
//            if UITraitCollection.userInterfaceStyle == .dark {
//                return UIColor(red: 14 / 255, green: 14 / 255, blue: 15 / 255, alpha: 1)
//            } else {
//                return UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)
//            }
//        }
    }

    // @todo there are probably better names for the following 2
    static var buttonBackground: UIColor {
        UIColor(red: 170 / 255, green: 139 / 255, blue: 255 / 255, alpha: 1)
    }

    static var lightButtonBackground: UIColor {
        UIColor(red: 193 / 255, green: 171 / 255, blue: 255 / 255, alpha: 1.0)
    }

    static var elementBackground: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .white
            }
        }
    }
}
