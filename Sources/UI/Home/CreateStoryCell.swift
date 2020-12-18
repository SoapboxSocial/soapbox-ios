import AlamofireImage
import UIKit

class CreateStoryCell: UICollectionViewCell {
    private var profileImage: UIImageView = {
        let view = UIImageView()
        view.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()

    private var image: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.brandColor.withAlphaComponent(0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = 48 / 2
        view.layer.masksToBounds = true

        let image = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 33, weight: .semibold)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .brandColor
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(profileImage)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            profileImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            profileImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
