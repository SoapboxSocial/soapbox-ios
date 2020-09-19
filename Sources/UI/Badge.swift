import UIKit

class Badge: UIView {
    // @TODO HAVE ENUM FOR BADGE ON CURRENT, OR OTHER ROOM?

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .brandColor
        layer.cornerRadius = 15

        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = NSLocalizedString("join_in", comment: "")
        badgeLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        badgeLabel.textColor = .white
        addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            badgeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            badgeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            badgeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
