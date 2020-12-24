import UIKit

class Button: UIButton {
    enum Size {
        case xsmall, small, regular, large
    }

    init(size: Size) {
        super.init(frame: .zero)

        backgroundColor = .brandColor
        layer.cornerRadius = 15

        switch size {
        case .xsmall:
            titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
            layer.cornerRadius = 10
        case .small:
            titleLabel?.font = .rounded(forTextStyle: .title3, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        case .regular:
            titleLabel?.font = .rounded(forTextStyle: .title2, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        case .large:
            titleLabel?.font = .rounded(forTextStyle: .title1, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
        }

        startAnimatingPressActions()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }

    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }

    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }

    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                button.transform = transform
            }
        )
    }
}
