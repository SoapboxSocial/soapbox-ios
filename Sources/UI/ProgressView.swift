import UIKit

class ProgressView: UIProgressView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let radius = frame.size.height / 2

        layer.cornerRadius = radius
        clipsToBounds = true
        layer.sublayers![1].cornerRadius = radius
        subviews[1].clipsToBounds = true
    }
}
