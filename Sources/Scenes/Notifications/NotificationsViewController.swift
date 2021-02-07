import NotificationBannerSwift
import UIKit

protocol NotificationsViewControllerOutput {
    func loadNotifications()
}

class NotificationsViewController: ViewController {
    var output: NotificationsViewControllerOutput!

    enum TimeFrame {
        case today, yesterday, thisWeek, earlier
    }

    struct Section {
        let time: TimeFrame
        let notifications: [APIClient.Notification]
    }

    private var notifications = [Section]()

    private var collection: UICollectionView!

    private let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        title = NSLocalizedString("activity", comment: "")

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .medium),
        ]

        collection = UICollectionView(frame: .zero, collectionViewLayout: layout())
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(cellWithClass: NotificationCell.self)
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.backgroundColor = .clear
        view.addSubview(collection)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadData()
    }

    @objc private func loadData() {
        output.loadNotifications()
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: .estimated(88)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 0
        section.boundarySupplementaryItems = [createSectionHeader()]

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(24)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
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
            self.collection.reloadData()
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
        case "GROUP_INVITE":
            let fmt = NSLocalizedString("invited_you_to_join", comment: "")
            body = String(format: fmt, notification.group?.name ?? "")
        case "WELCOME_ROOM":
            body = NSLocalizedString("just_joined_welcome", comment: "")
        default:
            body = ""
        }

        let cell = collectionView.dequeueReusableCell(withClass: NotificationCell.self, for: indexPath)
        cell.setText(name: notification.from.username, body: body, time: notification.timestamp)

        if notification.from.image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + notification.from.image))
        }

        cell.layer.mask = nil
        cell.layer.cornerRadius = 0

        if indexPath.item == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        }

        let count = notifications[indexPath.section].notifications.count
        if indexPath.item == (count - 1) {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        }

        if indexPath.item == 0, count == 1 {
            cell.layer.mask = nil
            cell.layer.cornerRadius = 30
            cell.layer.masksToBounds = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
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
        case "GROUP_INVITE":
            guard let id = item.group?.id else {
                return
            }

            nav.pushViewController(SceneFactory.createGroupViewController(id: id), animated: true)
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
