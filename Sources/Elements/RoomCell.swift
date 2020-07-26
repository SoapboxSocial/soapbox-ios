//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomCell: UICollectionViewCell {
    enum RoomCellStyle {
        case normal
    }

    public func setup(style: RoomCellStyle, isCurrent: Bool) {
        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 30))
        content.backgroundColor = .white
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)
<<<<<<< HEAD
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 30))
        titleLabel.text = title(style: style, isCurrent: isCurrent)
        content.addSubview(titleLabel)
    }

    private func title(style: RoomCellStyle, isCurrent: Bool) -> String {
        return "💬 " + NSLocalizedString("current_room", comment: "")
=======

        let emoji = UILabel(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 30))
        emoji.text = "💬"
        content.addSubview(emoji)
>>>>>>> master
    }
}
