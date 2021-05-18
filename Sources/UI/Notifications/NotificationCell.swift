import UIKit

class NotificationCell: CollectionViewCell {
    func setText(name: String? = nil, body: String) {
        let content = NSMutableAttributedString()

        if let name = name {
            content.append(NSMutableAttributedString(string: name + " ", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .semibold),
            ]))
        }

        content.append(NSAttributedString(string: body, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .regular),
        ]))

        title.attributedText = content
    }
}
