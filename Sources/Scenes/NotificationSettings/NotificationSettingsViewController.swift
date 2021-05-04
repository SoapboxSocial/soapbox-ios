import UIKit

class NotificationSettingsViewController: UIViewController {
    private let tableView = SettingsTableView()

    private var notificationsEdited = false
    private var notifications = APIClient.NotificationSettings(roomFrequency: .normal, follows: true, welcomeRooms: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Settings.Notifications.Title", comment: "")

        tableView.sections.append(SettingsTableView.Section(title: nil, data: [
            createRoomNotificationFrequencySetting(),
            SettingsTableView.Toggle(
                name: NSLocalizedString("Notifications.NewFollowers", comment: ""),
                isOn: { self.notifications.follows },
                handler: { value in
                    self.notificationsEdited = true
                    self.notifications.follows = value
                }
            ),
        ]))

        tableView.sections.append(SettingsTableView.Section(title: NSLocalizedString("Notifications.FromUs", comment: ""), data: [
            SettingsTableView.Toggle(
                name: NSLocalizedString("Notifications.WelcomeRooms", comment: ""),
                isOn: { self.notifications.welcomeRooms },
                handler: { value in
                    self.notificationsEdited = true
                    self.notifications.welcomeRooms = value
                }
            ),
        ]))

        view.backgroundColor = .background

        view.addSubview(tableView)

        let loading = UIView()
        loading.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)

        indicator.startAnimating()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        tableView.isUserInteractionEnabled = false

        APIClient().settings(callback: { result in
            switch result {
            case .failure:
                let banner = NotificationBanner(
                    title: NSLocalizedString("Settings.Errors.FailedToLoad", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger,
                    type: .floating
                )

                banner.show()
            case let .success(settings):
                self.notifications = settings.notifications
            }

            DispatchQueue.main.async {
                indicator.stopAnimating()
                self.tableView.isUserInteractionEnabled = true
                self.tableView.reloadData()
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !notificationsEdited {
            return
        }

        APIClient().updateNotificationSettings(frequency: notifications.roomFrequency, follows: notifications.follows, callback: { result in
            switch result {
            case .failure:
                let banner = NotificationBanner(
                    title: NSLocalizedString("Settings.Errors.FailedToSave", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger,
                    type: .floating
                )

                banner.show()
            case .success:
                break
            }
        })
    }

    private func createRoomNotificationFrequencySetting() -> SettingsTableView.Selection {
        SettingsTableView.Selection(
            name: NSLocalizedString("Notifications.RoomNotifications", comment: ""),
            handler: {
                let sheet = ActionSheet(
                    title: NSLocalizedString("Notifications.Frequency.Title", comment: ""),
                    description: NSLocalizedString("Notifications.Frequency.Description", comment: "")
                )

                func frequencyToggle(frequency: APIClient.Frequency) {
                    self.notificationsEdited = true
                    self.notifications.roomFrequency = frequency
                    self.tableView.reloadData()
                }

                sheet.add(action: ActionSheet.Action(title: self.title(forFrequency: .off), style: .default, handler: { _ in
                    frequencyToggle(frequency: .off)
                }))

                sheet.add(action: ActionSheet.Action(title: self.title(forFrequency: .infrequent), style: .default, handler: { _ in
                    frequencyToggle(frequency: .infrequent)
                }))

                sheet.add(action: ActionSheet.Action(title: self.title(forFrequency: .normal), style: .default, handler: { _ in
                    frequencyToggle(frequency: .normal)
                }))

                sheet.add(action: ActionSheet.Action(title: self.title(forFrequency: .frequent), style: .default, handler: { _ in
                    frequencyToggle(frequency: .frequent)
                }))

                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

                DispatchQueue.main.async {
                    self.present(sheet, animated: true)
                }
            },
            value: {
                self.title(forFrequency: self.notifications.roomFrequency)
            }
        )
    }

    private func title(forFrequency frequency: APIClient.Frequency) -> String {
        switch frequency {
        case .off:
            return NSLocalizedString("Notifications.Frequency.Off", comment: "")
        case .infrequent:
            return NSLocalizedString("Notifications.Frequency.Infrequent", comment: "")
        case .normal:
            return NSLocalizedString("Notifications.Frequency.Normal", comment: "")
        case .frequent:
            return NSLocalizedString("Notifications.Frequency.Frequent", comment: "")
        }
    }
}
