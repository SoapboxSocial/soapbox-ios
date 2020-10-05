import UIKit

class EmojiButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .background
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.width / 2
    }
}
