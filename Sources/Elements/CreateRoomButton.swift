import UIKit

class CreateRoomButton: UIButton {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))

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
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
