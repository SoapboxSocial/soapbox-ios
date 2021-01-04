import UIKit

public class BadgedButtonItem: UIBarButtonItem {
    private let radius = CGFloat(8.0)

    private let badge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.clipsToBounds = true
        return view
    }()

    public var tapAction: (() -> Void)?

    private let button = UIButton()

    override init() {
        super.init()
        setup()
    }

    init(with image: UIImage?) {
        super.init()
        setup(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func showBadge() {
        badge.isHidden = false
        badge.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 3,
            options: [.curveLinear],
            animations: {
                self.badge.transform = .identity
            },
            completion: { finished in
                if !finished {
                    self.badge.transform = .identity
                }
            }
        )
    }

    func hideBadge() {
        badge.isHidden = true
    }

    private func setup(image: UIImage? = nil) {
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.adjustsImageWhenHighlighted = false
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        badge.frame = CGRect(x: button.frame.maxX - radius * 2, y: 0, width: radius * 2, height: radius * 2)

        badge.layer.cornerRadius = radius
        badge.isHidden = true
        button.addSubview(badge)

        customView = button
    }

    @objc private func buttonPressed() {
        if let action = tapAction {
            action()
        }
    }
}
