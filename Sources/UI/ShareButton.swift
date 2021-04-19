import UIKit

class ShareButton: ButtonWithSpringAnimation {
    init(image: UIImage) {
        super.init()
        translatesAutoresizingMaskIntoConstraints = false
        setImage(image, for: .normal)
        tintColor = .white
        backgroundColor = .lightBrandColor
        adjustsImageWhenHighlighted = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.width / 2
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
