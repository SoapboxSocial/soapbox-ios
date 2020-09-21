import UIKit

class SoapButton: UIButton {
    enum Size {
        case small, regular, large
    }

    init(size _: Size) {
        super.init(frame: CGRect.zero)

        backgroundColor = .brandColor

        layer.cornerRadius = 15

        titleLabel?.font = .rounded(forTextStyle: .title3, weight: .bold)

        contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
