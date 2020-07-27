//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomListEmptyCell: UICollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        addSubview(titleLabel)
        addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleLabel.text = NSLocalizedString("no_active_rooms", comment: "")
        messageLabel.text = NSLocalizedString("start_room_tip", comment: "")
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
    }
}
