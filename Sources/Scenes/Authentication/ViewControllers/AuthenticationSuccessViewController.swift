import SwiftConfettiView
import UIKit

class AuthenticationSuccessViewController: UIViewController, AuthenticationStepViewController {
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
        label.textColor = .white
        label.text = NSLocalizedString("welcome", comment: "")
        return label
    }()

    private var confettiView: SwiftConfettiView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        confettiView = SwiftConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.startConfetti()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.confettiView.stopConfetti()
        }
    }
}
