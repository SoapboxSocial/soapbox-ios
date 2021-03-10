import UIKit

class DeleteAccountView: UIView {
    private let textField: TextField = {
        let field = TextField(frame: .zero, theme: .normal)
        field.textColor = .systemRed
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textAlignment = .center
        return field
    }()

    private let button: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.setTitle("Delete Account", for: .normal)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        button.setTitleColor(.label, for: .normal)
//        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(frame: .zero)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Deleting your account is an irreversible action, your account will be deleted immediately!"
        title.font = .rounded(forTextStyle: .title2, weight: .bold)
        title.textAlignment = .center
        title.numberOfLines = 0
        addSubview(title)

        let type = UILabel()
        type.translatesAutoresizingMaskIntoConstraints = false
        type.text = "Type \"DELETE\""
        type.font = .rounded(forTextStyle: .title3, weight: .regular)
        type.textAlignment = .center
        type.textColor = .secondaryLabel
        addSubview(type)

        addSubview(textField)
        addSubview(button)
        addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            type.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40),
            type.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            type.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: type.bottomAnchor, constant: 5),
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
