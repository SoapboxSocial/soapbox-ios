import UIKit

class ActiveUserCell: CollectionViewCell {
    let onlineIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16 / 2
        view.layer.borderColor = UIColor.background.cgColor
        view.layer.borderWidth = 3
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(onlineIndicator)

        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

        NSLayoutConstraint.activate([
            onlineIndicator.topAnchor.constraint(equalTo: topAnchor),
            onlineIndicator.heightAnchor.constraint(equalToConstant: 16),
            onlineIndicator.widthAnchor.constraint(equalToConstant: 16),
            onlineIndicator.rightAnchor.constraint(equalTo: image.rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onlineIndicator.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        onlineIndicator.layer.borderColor = UIColor.background.cgColor
    }
}
