import UIKit

class RoundButtonWithSpringAnimation: ButtonWithSpringAnimation {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }
}
