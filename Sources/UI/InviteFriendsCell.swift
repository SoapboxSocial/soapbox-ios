import LinkPresentation
import UIKit

class InviteFriendsCell: UICollectionViewCell {
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.text = NSLocalizedString("better_with_friends", comment: "")
        label.numberOfLines = 0
        return label
    }()

    private let button: Button = {
        let button = Button(size: .small)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("send_invite", comment: ""), for: .normal)
        return button
    }()

    private let heads: UIImageView = {
        let image = UIImageView(image: UIImage(named: "heads"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let sharing = MetadataItemSource(metadata: LPLinkMetadata())

    override init(frame _: CGRect) {
        super.init(frame: .zero)

        button.addTarget(self, action: #selector(share), for: .touchUpInside)

        contentView.addSubview(title)
        contentView.addSubview(button)
        contentView.addSubview(heads)

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            heads.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            heads.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func share() {
        let ac = UIActivityViewController(activityItems: [sharing], applicationActivities: nil)
        ac.excludedActivityTypes = [.markupAsPDF, .openInIBooks, .addToReadingList, .assignToContact, .print, .saveToCameraRoll]
        window!.rootViewController!.present(ac, animated: true)
    }
}
