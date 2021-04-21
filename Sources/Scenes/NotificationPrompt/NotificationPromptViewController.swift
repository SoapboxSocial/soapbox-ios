import UIKit

class NotificationPromptViewController: DrawerViewController {
    override init() {
        super.init()

        manager.drawer.openHeightBehavior = .fitting
        manager.drawer.backgroundColor = .foreground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .foreground

        let button = Button(size: .regular)
        button.setTitle("Take me to settings", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        let title = UILabel()
        title.text = "oh no!"
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .rounded(forTextStyle: .title1, weight: .bold)
        view.addSubview(title)

        let description = UILabel()
        description.text = "It looks like you have your notifications turned off, to get notified about more rooms like this one why not turn them back on?\n\n Our settings allow you to customize them to your preference!"
        description.numberOfLines = 0
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = .rounded(forTextStyle: .body, weight: .bold)
        view.addSubview(description)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            description.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            description.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
