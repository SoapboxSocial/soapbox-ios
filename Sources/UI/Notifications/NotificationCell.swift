import UIKit

class NotificationCell: CollectionViewCell {

    func setText(name: String, body: String, time _: Int) {
        let content = NSMutableAttributedString(string: name + "\n", attributes: [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .semibold),
        ])

        content.append(NSAttributedString(string: body, attributes: [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .regular),
        ]))

        title.attributedText = content
    }
}
