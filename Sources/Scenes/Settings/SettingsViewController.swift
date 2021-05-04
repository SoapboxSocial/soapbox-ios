import UIKit

class SettingsViewController: UIViewController {
    private let tableView = SettingsTableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("settings", comment: "")

        tableView.sections.append(
            SettingsTableView.Section(title: NSLocalizedString("appearance", comment: ""), data: [createThemeSetting()])
        )

        tableView.sections.append(
            SettingsTableView.Section(title: nil, data: [SettingsTableView.Plain(
                name: NSLocalizedString("Settings.Notifications.Title", comment: ""),
                handler: {
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(SceneFactory.createNotificationSettingsViewController(), animated: true)
                    }
                }
            )])
        )

        tableView.sections.append(SettingsTableView.Section(title: nil, data: [
            SettingsTableView.Link(name: NSLocalizedString("contact_us", comment: ""), link: URL(string: "mailto:support@soapbox.social")!),
            SettingsTableView.Link(name: NSLocalizedString("terms", comment: ""), link: URL(string: "https://soapbox.social/terms")!),
            SettingsTableView.Link(name: NSLocalizedString("privacy", comment: ""), link: URL(string: "https://soapbox.social/privacy")!),
        ]))

        tableView.sections.append(SettingsTableView.Section(title: nil, data: [SettingsTableView.Destructive(name: NSLocalizedString("delete_account", comment: ""), handler: {
            let view = DeleteAccountViewController()

            DispatchQueue.main.async {
                self.present(view, animated: true)
            }
        })]))

        view.backgroundColor = .background

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func createThemeSetting() -> SettingsTableView.Selection {
        return SettingsTableView.Selection(
            name: NSLocalizedString("theme", comment: ""),
            handler: {
                let sheet = ActionSheet()

                func themeToggle(theme: Theme) {
                    UserDefaults.standard.set(theme.rawValue, forKey: UserDefaultsKeys.theme)
                    self.tableView.reloadData()
                    (UIApplication.shared.delegate as! AppDelegate).setTheme()
                }

                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("system", comment: ""), style: .default, handler: { _ in
                    themeToggle(theme: .system)
                }))

                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("dark", comment: ""), style: .default, handler: { _ in
                    themeToggle(theme: .dark)
                }))

                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("light", comment: ""), style: .default, handler: { _ in
                    themeToggle(theme: .light)
                }))

                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

                DispatchQueue.main.async {
                    self.present(sheet, animated: true)
                }
            },
            value: {
                guard let setting = Theme(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.theme)) else {
                    return NSLocalizedString("system", comment: "")
                }

                switch setting {
                case .dark:
                    return NSLocalizedString("dark", comment: "")
                case .light:
                    return NSLocalizedString("light", comment: "")
                case .system:
                    return NSLocalizedString("system", comment: "")
                }
            }
        )
    }
}
