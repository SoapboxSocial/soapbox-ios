import UIKit

protocol NotificationsViewControllerOutput {
    func loadNotifications()
}

class NotificationsViewController: UIViewController {
    var output: NotificationsViewControllerOutput!

    private var notifications = [APIClient.Notification]()

    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        title = "Notifications"

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .medium),
        ]

        tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        output.loadNotifications()
    }
}

extension NotificationsViewController: NotificationsPresenterOutput {
    func display(notifications: [APIClient.Notification]) {
        self.notifications = notifications

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = notifications[indexPath.item]

        let cell = getCell(tableView)
        let title = NSLocalizedString(notification.alert.key, comment: "")
        cell.textLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        cell.textLabel?.text = String(format: title, arguments: notification.alert.arguments)

        return cell
    }

    private func getCell(_ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") {
            return cell
        }

        return UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
    }
}
