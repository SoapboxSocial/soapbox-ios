import UIKit

class CollectionViewSectionTitle: UICollectionReusableView {
    var label: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)

        label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
