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
        view.backgroundColor = .background
        view.clipsToBounds = true
        view.layer.cornerRadius = 26 / 2
        view.layer.masksToBounds = true

        let image = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 4, weight: .bold)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .white
        image.backgroundColor = .brandColor
        image.layer.cornerRadius = 20 / 2
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -6),
            image.heightAnchor.constraint(equalTo: image.widthAnchor),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(profileImage)
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            profileImage.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            profileImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 3),
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            image.widthAnchor.constraint(equalToConstant: 26),
            image.heightAnchor.constraint(equalToConstant: 26),
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
