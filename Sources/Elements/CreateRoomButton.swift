import UIKit

class CreateRoomButton: ButtonWithSpringAnimation {
    private let feedback: UIImpactFeedbackGenerator = {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        return feedback
    }()

    override init() {
        super.init()

        frame.size = CGSize(width: 70, height: 70)

        backgroundColor = .brandColor
        layer.cornerRadius = frame.size.height / 2

        layer.masksToBounds = false

        layer.addSublayer(shadowLayer(alpha: 0.02, radius: 1.94, height: 2.42))
        layer.addSublayer(shadowLayer(alpha: 0.03, radius: 4.66, height: 5.82))
        layer.addSublayer(shadowLayer(alpha: 0.04, radius: 8.77, height: 10.96))
        layer.addSublayer(shadowLayer(alpha: 0.04, radius: 15.64, height: 19.54))
        layer.addSublayer(shadowLayer(alpha: 0.05, radius: 29.24, height: 36.56))
        layer.addSublayer(shadowLayer(alpha: 0.07, radius: 70, height: 87.5))

        setImage(
            UIImage(systemName: "quote.bubble.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)),
            for: .normal
        )

        tintColor = .white
        imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)

        addTarget(self, action: #selector(didPress), for: [.touchUpInside])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didPress() {
        feedback.impactOccurred()
        feedback.prepare()
    }

    func shadowLayer(alpha: CGFloat, radius: CGFloat, height: CGFloat) -> CALayer {
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)

        let layer = CALayer()
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.black.withAlphaComponent(alpha).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.bounds = bounds
        layer.position = center

        return layer
    }
}
