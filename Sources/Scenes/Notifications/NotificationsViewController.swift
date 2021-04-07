import UIKit

protocol NotificationsViewControllerOutput {
    func loadNotifications()
}

class NotificationsViewController: ViewControllerWithScrollableContent<UICollectionView> {
    var output: NotificationsViewControllerOutput!

    enum TimeFrame {
        case today, yesterday, thisWeek, earlier
    }

    struct Section {
        let time: TimeFrame
        let notifications: [APIClient.Notification]
    }

    private var notifications = [Section]()

    private let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        title = NSLocalizedString("activity", comment: "")

        content = UICollectionView(frame: .zero, collectionViewLayout: layout())
        content.dataSource = self
        content.delegate = self
        content.translatesAutoresizingMaskIntoConstraints = false
        content.register(cellWithClass: NotificationCell.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)
        content.backgroundColor = .clear
        view.addSubview(content)

        content.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadData()
    }

    @objc private func loadData() {
        output.loadNotifications()
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self.content.section(hasHeader: true, hasFooter: sectionIndex + 1 == self.notifications.count)
        }

        layout.register(CollectionBackgroundView.self, forDecorationViewOfKind: "background")
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }
}

extension NotificationsViewController: NotificationsPresenterOutput {
    func display(notifications: [APIClient.Notification]) {
        self.notifications = [Section]()
        let sorted = Dictionary(grouping: notifications, by: { (notification) -> TimeFrame in
            let date = Date(timeIntervalSince1970: TimeInterval(notification.timestamp))

            if date.isToday() {
                return .today
            }

            if date.isYesterday() {
                return .yesterday
            }

            if date.isThisWeek() {
                return .thisWeek
            }

            return .earlier
        })

        if let today = sorted[.today], !today.isEmpty {
            self.notifications.append(Section(time: .today, notifications: today))
        }

        if let yesterday = sorted[.yesterday], !yesterday.isEmpty {
            self.notifications.append(Section(time: .yesterday, notifications: yesterday))
        }

        if let thisWeek = sorted[.thisWeek], !thisWeek.isEmpty {
            self.notifications.append(Section(time: .thisWeek, notifications: thisWeek))
        }

        if let earlier = sorted[.earlier], !earlier.isEmpty {
            self.notifications.append(Section(time: .earlier, notifications: earlier))
        }

        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            self.content.reloadData()
        }
    }

    func displayError() {
        let banner = NotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger,
            type: .floating
        )
        banner.show()
    }
}

extension NotificationsViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return notifications.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications[section].notifications.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let notification = notifications[indexPath.section].notifications[indexPath.item]

        var body: String

        switch notification.category {
        case "NEW_FOLLOWER":
            body = NSLocalizedString("started_following_you", comment: "")
        case "WELCOME_ROOM":
            body = NSLocalizedString("just_joined_welcome", comment: "")
        default:
            body = ""
        }

        let cell = collectionView.dequeueReusableCell(withClass: NotificationCell.self, for: indexPath)
        cell.setText(name: notification.from.username, body: body)

        if notification.from.image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + notification.from.image))
        }

        return cell
    }

    func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return content.dequeueReusableSupplementaryView(ofKind: kind, withClass: EmptyCollectionFooterView.self, for: indexPath)
        }

        let cell = content.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
        cell.label.font = .rounded(forTextStyle: .title3, weight: .bold)

        switch notifications[indexPath.section].time {
        case .today:
            cell.label.text = NSLocalizedString("today", comment: "")
        case .yesterday:
            cell.label.text = NSLocalizedString("yesterday", comment: "")
        case .thisWeek:
            cell.label.text = NSLocalizedString("this_week", comment: "")
        case .earlier:
            cell.label.text = NSLocalizedString("earlier", comment: "")
        }

        return cell
    }
}

extension NotificationsViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // @TODO INTERACTOR
        let item = notifications[indexPath.section].notifications[indexPath.item]

        guard let nav = navigationController as? NavigationViewController else {
            return
        }

        switch item.category {
        case "NEW_FOLLOWER":
            nav.pushViewController(SceneFactory.createProfileViewController(id: item.from.id), animated: true)
        case "WELCOME_ROOM":
            guard let room = item.room else {
                return
            }

            nav.didSelect(room: room)
        default:
            return
        }
    }
}
