import UIKit

class Button: UIButton {
    enum Size {
        case small, regular, large
    }

    init(size: Size) {
        super.init(frame: CGRect.zero)

        backgroundColor = .brandColor
        layer.cornerRadius = 15

        switch size {
        case .small:
            titleLabel?.font = .rounded(forTextStyle: .title3, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        case .regular:
            titleLabel?.font = .rounded(forTextStyle: .title2, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        case .large:
            titleLabel?.font = .rounded(forTextStyle: .title1, weight: .bold)
            contentEdgeInsets = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}