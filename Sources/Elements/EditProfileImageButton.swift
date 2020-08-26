import UIKit

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

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        label.text = NSLocalizedString("edit", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)

        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
}
