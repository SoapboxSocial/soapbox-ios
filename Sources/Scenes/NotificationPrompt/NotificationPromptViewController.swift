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

        let text = UILabel()
        text.text = "oh no!"
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = .rounded(forTextStyle: .title1, weight: .bold)
        view.addSubview(text)

        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 20),
            text.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            text.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 20),
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
