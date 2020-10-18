import UIKit

class ActiveUserCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 15
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
