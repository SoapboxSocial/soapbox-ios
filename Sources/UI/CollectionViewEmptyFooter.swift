import UIKit

class CollectionViewEmptyFooter: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        heightAnchor.constraint(equalToConstant: 105).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
