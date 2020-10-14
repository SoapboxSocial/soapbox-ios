import UIKit

// @TODO USE CONSTRAINTS

class EditProfileImageButton: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTarget(_ target: Any, action: Selector) {
        let imageTap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(imageTap)
        isUserInteractionEnabled = true
    }

    private func setup() {
        layer.cornerRadius = frame.size.width / 2
        backgroundColor = .secondaryBackground
        clipsToBounds = true

        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(view)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)
        let image = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: iconConfig))
        image.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        image.contentMode = .scaleAspectFill
        image.tintColor = .white
        image.center = view.center

        view.addSubview(image)
    }
}
