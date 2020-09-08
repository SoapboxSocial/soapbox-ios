import UIKit

// @TODO: Probably wanna change the text if you're on your own room.

class CurrentRoomView: UIView {
    var displayName: String! {
        didSet {
            currentNameLabel.text = String(format: NSLocalizedString("is_currently_in_room", comment: ""), displayName.firstName())
        }
    }

    private var currentNameLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor.elementBackground
        layer.cornerRadius = 8
        layer.masksToBounds = true

        currentNameLabel = UILabel(frame: CGRect(x: 15, y: 15, width: frame.size.width - 30, height: 30))
        currentNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: currentNameLabel.font.pointSize)
        currentNameLabel.text = ""
        addSubview(currentNameLabel)

        let listenLabel = UILabel(frame: CGRect(x: 15, y: 45, width: frame.size.width - 30, height: 30))
        listenLabel.textColor = .secondaryBackground
        listenLabel.text = NSLocalizedString("click_to_join", comment: "")
        addSubview(listenLabel)
    }
}
