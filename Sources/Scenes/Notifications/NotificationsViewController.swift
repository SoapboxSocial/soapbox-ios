import NotificationBannerSwift
import UIKit

protocol NotificationsViewControllerOutput {
    func loadNotifications()
}

class NotificationsViewController: UIViewController {
    var output: NotificationsViewControllerOutput!

    private var notifications = [APIClient.Notification]()

    private var tableView: UITableView!

    private let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        title = NSLocalizedString("notifications", comment: "")

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .medium),
        ]

        tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        view.addSubview(tableView)

        loadData()
    }

    @objc private func loadData() {
        output.loadNotifications()
    }
}

extension NotificationsViewController: NotificationsPresenterOutput {
    func display(notifications: [APIClient.Notification]) {
        self.notifications = notifications

        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            self.tableView.reloadData()
        }
    }

    func displayError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
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
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping

        return cell
    }

    private func getCell(_ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") {
            return cell
        }

        return UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // @TODO MOVE TO INTERACTOR:
        let item = notifications[indexPath.item]

        guard let nav = navigationController as? NavigationViewController else {
            return
        }

        switch item.category {
        case "NEW_ROOM", "ROOM_JOINED", "ROOM_INVITE":
            guard let id = item.arguments["id"] else {
                return
            }

            nav.didSelect(room: id)
        case "NEW_FOLLOWER":
            guard let id = item.arguments["id"] else {
                return
            }

            nav.pushViewController(SceneFactory.createProfileViewController(id: id), animated: true)
        default:
            break
        }
    }
}
