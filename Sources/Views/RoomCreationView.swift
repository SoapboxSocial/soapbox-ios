import UIKit

protocol RoomCreationDelegate {
    func didCancelRoomCreation()
    func didEnterWithName(_ name: String?, isPrivate: Bool)
}

class RoomCreationView: UIView, UITextFieldDelegate {
    var delegate: RoomCreationDelegate?

    private let visibilityControl: SegmentedControl = {
        let control = SegmentedControl(frame: CGRect.zero, titles: [
            NSLocalizedString("public", comment: ""),
            NSLocalizedString("private", comment: ""),
        ])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let textField: UITextField = {
        let field = TextField(frame: CGRect.zero, theme: .light)
        field.placeholder = NSLocalizedString("enter_name", comment: "")
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cancelPressed))

        let cancel = UILabel()
        cancel.font = .rounded(forTextStyle: .body, weight: .medium)
        cancel.text = NSLocalizedString("cancel", comment: "")
        cancel.textColor = .white
        cancel.addGestureRecognizer(recognizer)
        cancel.isUserInteractionEnabled = true
        cancel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancel)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("create_a_room", comment: "")
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        textField.delegate = self
        addSubview(textField)

        addSubview(visibilityControl)

        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.backgroundColor = .lightBrandColor
        button.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        addSubview(button)

        let mutedText = UILabel()
        mutedText.text = NSLocalizedString("you_will_be_muted_by_default", comment: "")
        mutedText.font = .rounded(forTextStyle: .body, weight: .semibold)
        mutedText.textColor = .white
        mutedText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mutedText)

        NSLayoutConstraint.activate([
            cancel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            visibilityControl.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            visibilityControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            visibilityControl.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            visibilityControl.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: visibilityControl.bottomAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            mutedText.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            mutedText.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            mutedText.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.count ?? 0) + (string.count - range.length) < 30
    }

    @objc private func createPressed() {
        delegate?.didEnterWithName(textField.text, isPrivate: visibilityControl.index == 1)
    }

    @objc private func cancelPressed() {
        delegate?.didCancelRoomCreation()
    }
}
