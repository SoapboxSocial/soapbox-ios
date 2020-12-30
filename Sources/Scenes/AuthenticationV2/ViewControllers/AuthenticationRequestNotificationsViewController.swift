import UIKit

class AuthenticationRequestNotificationsViewController: UIViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.text = NSLocalizedString("enable_notifications", comment: "")
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
}
