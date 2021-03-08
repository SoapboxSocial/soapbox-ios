import UIKit

class RoomMemberAccessoryView: UIView {
    init(image: UIImage, frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = false
        clipsToBounds = true

        let imageView = UIImageView(image: image)
        imageView.center = center
        imageView.tintColor = .white

        addSubview(imageView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
