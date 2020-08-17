//
import AlamofireImage
//  UserCell.swift
//  Voicely
//
//  Created by Dean Eigenmann on 10.08.20.
//
import UIKit

class UserCell: UICollectionViewCell {
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var profilePicture: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 15))
        content.backgroundColor = .elementBackground
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)

        profilePicture = UIImageView(frame: CGRect(x: 20, y: 20, width: content.frame.size.height - 40, height: content.frame.size.height - 40))
        profilePicture.layer.cornerRadius = (content.frame.size.height - 40) / 2
        profilePicture.backgroundColor = .systemGray5

        content.addSubview(profilePicture)

        nameLabel = UILabel(frame: CGRect(x: profilePicture.frame.size.width + profilePicture.frame.origin.x + 20, y: 15, width: contentView.frame.size.width - (profilePicture.frame.size.width + profilePicture.frame.origin.x + 20), height: 30))
        nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: nameLabel.font.pointSize)
        content.addSubview(nameLabel)

        usernameLabel = UILabel(frame: CGRect(x: nameLabel.frame.origin.x, y: 45, width: contentView.frame.size.width - 30, height: 30))
        content.addSubview(usernameLabel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setup(user: APIClient.User) {
        nameLabel.text = user.displayName
        usernameLabel.text = "@" + user.username

        if let image = user.image {
            profilePicture.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }
}
