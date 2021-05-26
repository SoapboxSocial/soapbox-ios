import UIKit

class AuthenticationRequestNotificationsViewController: UIViewController, AuthenticationStepViewController {
    var stepDescription: String? {
        return nil
    }

    var hasBackButton: Bool {
        return false
    }

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.text = NSLocalizedString("enable_notifications", comment: "")
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let dude = UIImageView(image: UIImage(named: "bluedude.notifications"))
        dude.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dude)

        NSLayoutConstraint.activate([
            dude.rightAnchor.constraint(equalTo: view.rightAnchor),
            dude.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
}
