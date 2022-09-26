import UIKit

class SoapButton: ButtonWithSpringAnimation {
    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.25
        }
    }

    enum Size {
        case xsmall, small, regular, large
    }

    init(size: Size) {
        super.init()

        backgroundColor = .brandColor
        layer.cornerRadius = 15

        switch size {
        case .xsmall:
            titleLabel?.font = .rounded(forTextStyle: .body, weight: .semibold)
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
            layer.cornerRadius = 10
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
