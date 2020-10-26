import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool)
}

class RoomCreationView: UIView, UITextFieldDelegate {
    var delegate: RoomCreationDelegate?

    private var visibilityControl: SegmentedControl!
    private var textField: UITextField!

    override func layoutSubviews() {
        super.layoutSubviews()

        if textField != nil { return }

        roundCorners(corners: [.topLeft, .topRight], radius: 25.0)

        backgroundColor = .brandColor

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cancelPressed))

        let cancel = UILabel()
        cancel.font = .rounded(forTextStyle: .body, weight: .medium)
        cancel.text = NSLocalizedString("cancel", comment: "")
        cancel.textColor = .white
        cancel.sizeToFit()
        cancel.frame = CGRect(origin: CGPoint(x: 20, y: 20), size: cancel.frame.size)
        cancel.addGestureRecognizer(recognizer)
        cancel.isUserInteractionEnabled = true
        addSubview(cancel)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("create_a_room", comment: "")
        title.textColor = .white
        title.sizeToFit()
        title.frame = CGRect(origin: CGPoint(x: 20, y: cancel.frame.size.height + cancel.frame.origin.y + 20), size: title.frame.size)
        addSubview(title)

        textField = TextField(frame: CGRect(x: 20, y: title.frame.origin.y + title.frame.size.height + 30, width: frame.size.width - 40, height: 56), theme: .light)
        textField.placeholder = NSLocalizedString("enter_name", comment: "")
        textField.delegate = self
        addSubview(textField)

        visibilityControl = SegmentedControl(
            frame: CGRect(x: 20, y: textField.frame.origin.y + title.frame.size.height + 30, width: frame.size.width - 40, height: 56),
            titles: [NSLocalizedString("public", comment: ""), NSLocalizedString("private", comment: "")]
        )
        addSubview(visibilityControl)

        let button = Button(size: .large)
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.frame = CGRect(x: 20, y: visibilityControl.frame.origin.y + visibilityControl.frame.size.height + 20, width: frame.size.width - 40, height: 54)
        button.backgroundColor = .lightBrandColor
        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        addSubview(button)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func createPressed() {
        delegate?.didEnterWithName(textField.text, isPrivate: visibilityControl.index == 1)
    }

    @objc private func cancelPressed() {
        delegate?.didCancelRoomCreation()
    }
}
