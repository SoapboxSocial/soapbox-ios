import UIKit

class GradientView: UIView {
    private let color: UIColor

    private let gradient: CAGradientLayer

    init(color: UIColor) {
        self.color = color
        gradient = CAGradientLayer()

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        gradient.masksToBounds = true
        gradient.colors = [color.withAlphaComponent(0.0).cgColor, color.withAlphaComponent(1.0).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.3)
        layer.addSublayer(gradient)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        gradient.colors = [color.withAlphaComponent(0.0).cgColor, color.withAlphaComponent(1.0).cgColor]
    }
}
