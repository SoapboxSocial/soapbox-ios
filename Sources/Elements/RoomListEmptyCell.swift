//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomListEmptyCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black // @todo
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = .lightGray
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
