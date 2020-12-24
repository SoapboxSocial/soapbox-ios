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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.0

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
}
