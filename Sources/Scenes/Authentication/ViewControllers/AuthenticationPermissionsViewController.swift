import AVFoundation
import UIKit

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
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func micPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                self.microphoneButton.isSelected = true
            }
        }
    }

    @objc private func notificationPermissions() {
        NotificationManager.shared.requestAuthorization(callback: { _ in
            DispatchQueue.main.async {
                self.notificationsButton.isSelected = true
            }
        })
    }
}
