import UIKit

class RoomMemberAccessoryViewWithGradient: RoomMemberAccessoryView {
    override init(image: UIImage, frame: CGRect) {
        super.init(image: image, frame: frame)

        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor(red: 0.514, green: 0.349, blue: 0.996, alpha: 1).cgColor,
            UIColor(red: 0.263, green: 0.031, blue: 0.765, alpha: 1).cgColor,
        ]

        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        gradient.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 1, c: -1, d: 1, tx: 0.5, ty: -0.5))

        layer.insertSublayer(gradient, at: 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
