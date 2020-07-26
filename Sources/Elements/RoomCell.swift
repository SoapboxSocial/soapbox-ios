//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomCell: UICollectionViewCell {
    enum RoomCellStyle {
        case normal
        case current
    }

    public func setup(style: RoomCellStyle) {
        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 30))
        content.backgroundColor = .white
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)

        let titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 30))
        titleLabel.text = title(style: style)
        content.addSubview(titleLabel)

        let countLabel = UILabel(frame: CGRect(x: 15, y: 45, width: contentView.frame.size.width - 30, height: 30))
        countLabel.text = "139 Participants"
        countLabel.textColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)
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
