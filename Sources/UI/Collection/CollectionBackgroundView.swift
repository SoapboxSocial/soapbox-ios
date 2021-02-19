import UIKit

class CollectionBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .foreground
        layer.cornerRadius = 30
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
