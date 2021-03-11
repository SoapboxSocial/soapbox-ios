import DrawerView
import UIKit

class DeleteAccountViewController: UIViewController {
    private let textField: TextField = {
        let field = TextField(frame: .zero, theme: .normal)
        field.textColor = .systemRed
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textAlignment = .center
        return field
    }()

    private let button: ButtonWithLoadingIndicator = {
        let button = ButtonWithLoadingIndicator(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.setTitle(NSLocalizedString("delete_account", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        return button
    }()

    private let manager: DrawerPresentationManager = {
        let manager = DrawerPresentationManager()
        manager.drawer.backgroundColor = .background
        manager.drawer.backgroundEffect = nil
        manager.drawer.cornerRadius = 30
        return manager
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = manager
        modalPresentationStyle = .custom
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("deleting_is_permanent", comment: "")
        title.font = .rounded(forTextStyle: .title2, weight: .bold)
        title.textAlignment = .center
        title.numberOfLines = 0
        view.addSubview(title)

        let type = UILabel()
        type.translatesAutoresizingMaskIntoConstraints = false
        type.text = NSLocalizedString("type_delete", comment: "")
        type.font = .rounded(forTextStyle: .title3, weight: .regular)
        type.textAlignment = .center
        type.textColor = .secondaryLabel
        view.addSubview(type)

        view.addSubview(textField)
        view.addSubview(button)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            type.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40),
            type.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            type.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: type.bottomAnchor, constant: 5),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    @objc private func deletePressed() {
        let warning = NotificationBanner(
            title: NSLocalizedString("type_delete_confirmation", comment: ""),
            style: .warning
        )

        guard let text = textField.text else {
            warning.show()
            return
        }

        if text != NSLocalizedString("delete_caps", comment: "") {
            warning.show()
            return
        }

        button.isLoading = true

        APIClient().deleteAccount { result in
            DispatchQueue.main.async {
                self.button.isLoading = false
            }

            switch result {
            case .failure:
                let banner = NotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger,
                    type: .floating
                )

                DispatchQueue.main.async {
                    banner.show()
                }
            case .success:
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        DispatchQueue.main.async {
                            (UIApplication.shared.delegate as! AppDelegate).transitionToLoginView()
                        }
                    })
                }
            }
        }
    }

    @objc private func cancelPressed() {
        dismiss(animated: true)
    }
}
