//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomCell: UICollectionViewCell {
    enum RoomCellStyle {
        case normal
        case current
    }

    public func setup(style: RoomCellStyle, data: APIClient.Room) {
        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 15))
        content.backgroundColor = UIColor.elementBackground
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)

        let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 30))
        titleLabel.text = title(style: style)
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabel.font.pointSize)
        content.addSubview(titleLabel)

        let countLabel = UILabel(frame: CGRect(x: 15, y: 45, width: contentView.frame.size.width - 30, height: 30))
        if data.members.count == 1 {
            countLabel.text = String(data.members.count) + " " + NSLocalizedString("participant", comment: "")
        } else {
            countLabel.text = String(data.members.count) + " " + NSLocalizedString("participants", comment: "")
        }

        countLabel.textColor = .highlight
        content.addSubview(countLabel)
    }

    private func title(style: RoomCellStyle) -> String {
        switch style {
        case .normal:
            return "👂 " + NSLocalizedString("listen_in", comment: "")
        case .current:
            return "💬 " + NSLocalizedString("current_room", comment: "")
        }
    }
}
