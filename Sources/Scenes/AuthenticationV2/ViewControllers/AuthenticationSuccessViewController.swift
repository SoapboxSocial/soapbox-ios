import SwiftConfettiView
import UIKit

class AuthenticationSuccessViewController: UIViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        label.text = NSLocalizedString("welcome", comment: "")
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        let confettiView = SwiftConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.startConfetti()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            confettiView.stopConfetti()
        }
    }
}
