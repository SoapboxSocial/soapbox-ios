import UIKit

class NotificationPromptViewController: DrawerViewController {
    enum PromptType {
        case afterRoom, startup

        var title: String {
            switch self {
            case .afterRoom:
                return "NotificationPrompt.AfterRoom.Title"
            case .startup:
                return "NotificationPrompt.Startup.Title"
            }
        }

        var description: String {
            switch self {
            case .afterRoom:
                return "NotificationPrompt.AfterRoom.Description"
            case .startup:
                return "NotificationPrompt.Startup.Description"
            }
        }
    }

    let type: PromptType

    init(_ type: PromptType) {
        self.type = type
        super.init()

        manager.drawer.openHeightBehavior = .fitting
        manager.drawer.backgroundColor = .brandColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

        let image = UIImageView(image: UIImage(named: "dude.notification"))
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString(type.title, comment: "")
        title.font = .rounded(forTextStyle: .title1, weight: .bold)
        title.numberOfLines = 0
        title.textColor = .white
        title.textAlignment = .center
        view.addSubview(title)

        let content = UILabel()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.text = NSLocalizedString(type.description, comment: "")
        content.numberOfLines = 0
        content.textColor = .white
        content.font = .rounded(forTextStyle: .body, weight: .semibold)
        view.addSubview(content)

        let settingsButton = Button(size: .large)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.backgroundColor = .white
        settingsButton.setTitle("Go to Settings", for: .normal)
        settingsButton.setTitleColor(.black, for: .normal)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)

        let cancelButton = UIButton()
        cancelButton.setTitle("Not Now", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = .rounded(forTextStyle: .title3, weight: .bold)
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 40),
        ])

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60),
            title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            content.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40),
        ])

        NSLayoutConstraint.activate([
            settingsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            settingsButton.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 80),
        ])

        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            cancelButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
