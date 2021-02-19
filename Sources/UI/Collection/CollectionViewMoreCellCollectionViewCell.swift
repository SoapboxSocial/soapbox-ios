import UIKit

class CollectionViewMoreCellCollectionViewCell: UICollectionViewCell {
    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        label.textColor = .label
        label.text = NSLocalizedString("view_more", comment: "")
        label.textAlignment = .center
        return label
    }()

    private var seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(seperator)
        contentView.addSubview(title)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: topAnchor),
            seperator.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            seperator.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            seperator.heightAnchor.constraint(equalToConstant: 2),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
