import UIKit

class EmptyRoomCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height - 200).isActive = true

        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        titleLabel.font = .rounded(forTextStyle: .title1, weight: .bold)
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        addSubview(titleLabel)
        addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleLabel.lineBreakMode = .byWordWrapping
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleLabel.text = NSLocalizedString("no_one_talking", comment: "")
        titleLabel.textAlignment = .center
        messageLabel.text = NSLocalizedString("start_a_room", comment: "")
        messageLabel.textAlignment = .center
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
