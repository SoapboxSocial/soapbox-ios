import UIKit

class AuthenticationPinViewController: ViewControllerWithKeyboardConstraint {
    private let textField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.placeholder = NSLocalizedString("pin", comment: "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        return textField
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
//        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return button
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        return label
    }()

    private var isDisappearing = false

    init() {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(submitButton)

        bottomLayoutConstraint = submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height / 3))
        bottomLayoutConstraint.isActive = true

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
            textField.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
}
