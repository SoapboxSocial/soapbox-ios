//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class RoomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear

        let content = UIView(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: frame.size.height - 30))
        content.backgroundColor = .white
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        addSubview(content)

        let emoji = UILabel(frame: CGRect(x: 15, y: 15, width: contentView.frame.size.width - 30, height: 30))
        emoji.text = "💬"
        content.addSubview(emoji)
    }
}
