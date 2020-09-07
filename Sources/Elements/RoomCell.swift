//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomCell: UICollectionViewCell {
    enum RoomCellStyle {
        case normal
        case current
    }

    var titleLabel: UILabel!
    var countLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 15))
        content.backgroundColor = UIColor.elementBackground
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)

        titleLabel = UILabel(frame: CGRect(x: 15, y: 15, width: content.frame.size.width - 30, height: 30))
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabel.font.pointSize)
        content.addSubview(titleLabel)

        countLabel = UILabel(frame: CGRect(x: 15, y: 45, width: content.frame.size.width - 30, height: 30))
        countLabel.textColor = .secondaryBackground
        content.addSubview(countLabel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setup(style: RoomCellStyle, data: RoomState) {
        titleLabel.text = title(room: data, style: style)

        if data.members.count == 1 {
            countLabel!.text = String(data.members.count) + " " + NSLocalizedString("participant", comment: "")
        } else {
            countLabel!.text = String(data.members.count) + " " + NSLocalizedString("participants", comment: "")
        }
    }

    private func title(room: RoomState, style: RoomCellStyle) -> String {
        switch style {
        case .normal:
            if room.name != "" {
                return "👂 " + room.name
            }

            return "👂 " + NSLocalizedString("listen_in", comment: "")
        case .current:
            return "💬 " + NSLocalizedString("current_room", comment: "")
        }
    }
}
