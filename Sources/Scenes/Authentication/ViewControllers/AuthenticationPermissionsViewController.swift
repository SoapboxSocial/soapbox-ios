import AVFoundation
import UIKit

protocol AuthenticationPermissionsViewControllerDelegate: AnyObject {
    func didFinishPermissions()
}

class AuthenticationPermissionsViewController: UIViewController, AuthenticationStepViewController {
    var hasBackButton: Bool {
        return false
    }

    var hasSkipButton: Bool {
        return false
    }

    var stepDescription: String? {
        return NSLocalizedString("Authentication.Permissions.Description", comment: "")
    }

    var delegate: AuthenticationPermissionsViewControllerDelegate?

    private let microphoneButton: PermissionButton = {
        let button = PermissionButton()
        button.title.text = NSLocalizedString("Authentication.Permissions.Microphone", comment: "")
        button.emoji.text = "🎙"
        button.descriptionLabel.text = NSLocalizedString("Authentication.Permissions.Microphone.Description", comment: "")
        return button
    }()

    private let notificationsButton: PermissionButton = {
        let button = PermissionButton()
        button.title.text = NSLocalizedString("Authentication.Permissions.Notifications", comment: "")
        button.emoji.text = "🔔"
        button.descriptionLabel.text = NSLocalizedString("Authentication.Permissions.Notifications.Description", comment: "")
        return button
    }()

    let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Authentication.Permissions", comment: "")

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 30
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        view.addSubview(stack)

        microphoneButton.addTarget(self, action: #selector(micPermissions), for: .touchUpInside)
        stack.addArrangedSubview(microphoneButton)

        notificationsButton.addTarget(self, action: #selector(notificationPermissions), for: .touchUpInside)
        stack.addArrangedSubview(notificationsButton)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    func enableSubmit() {
        // do nothing
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func micPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                self.microphoneButton.isSelected = true
                self.enableNext()
            }
        }
    }

    @objc private func notificationPermissions() {
        NotificationManager.shared.requestAuthorization(callback: { _ in
            DispatchQueue.main.async {
                self.notificationsButton.isSelected = true
                self.enableNext()
            }
        })
    }

    @objc private func didSubmit() {
        delegate?.didFinishPermissions()
    }

    private func enableNext() {
        if !notificationsButton.isSelected || !microphoneButton.isSelected {
            return
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.submitButton.isEnabled = true
        })
    }
}
