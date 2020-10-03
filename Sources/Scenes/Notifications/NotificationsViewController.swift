import UIKit

class NotificationsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        title = "Notifications"

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .medium),
        ]
    }
}
