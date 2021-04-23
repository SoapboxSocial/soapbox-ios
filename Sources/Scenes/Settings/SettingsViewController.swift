import UIKit

class SettingsViewController: UIViewController {
    private let presenter = SettingsPresenter()

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellWithClass: SettingsLinkTableViewCell.self)
        view.register(cellWithClass: SettingsSelectionTableViewCell.self)
        view.register(cellWithClass: SettingsToggleTableViewCell.self)
        view.register(cellWithClass: SettingsDestructiveTableViewCell.self)
        view.backgroundColor = .background
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("settings", comment: "")
        title.font = .rounded(forTextStyle: .headline, weight: .semibold)
        view.addSubview(title)

        presenter.set(appearance: [
            createThemeSetting(),
        ])

        presenter.set(notifications: [
            SettingsPresenter.Selection(name: NSLocalizedString("Settings.Notifications.RoomNotifications", comment: ""), handler: {}, value: { "Normal" }),
            SettingsPresenter.Toggle(name: NSLocalizedString("Settings.Notifications.NewFollowers", comment: ""), isOn: true),
        ])

        presenter.set(links: [
            SettingsPresenter.Link(name: NSLocalizedString("contact_us", comment: ""), link: URL(string: "mailto:support@soapbox.social")!),
            SettingsPresenter.Link(name: NSLocalizedString("terms", comment: ""), link: URL(string: "https://soapbox.social/terms")!),
            SettingsPresenter.Link(name: NSLocalizedString("privacy", comment: ""), link: URL(string: "https://soapbox.social/privacy")!),
        ])

        presenter.set(deleteAccount: SettingsPresenter.Destructive(name: NSLocalizedString("delete_account", comment: ""), handler: {
            let view = DeleteAccountViewController()

            DispatchQueue.main.async {
                self.present(view, animated: true)
            }
        }))

        view.backgroundColor = .background

        let close = UIButton()
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = .brandColor
        close.translatesAutoresizingMaskIntoConstraints = false
        close.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.addSubview(close)

        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        tableView.reloadData()

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: close.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            close.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            close.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            close.widthAnchor.constraint(equalToConstant: 20),
            close.heightAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let header = tableView.rectForHeader(inSection: 1)
        let footer = tableView.rectForFooter(inSection: 1)
        let rect = tableView.rect(forSection: 1)

        let view = UIView(frame: CGRect(
            x: rect.origin.x,
            y: rect.origin.y + header.height,
            width: rect.width,
            height: rect.height - (header.height + footer.height)
        ))
        view.backgroundColor = UIColor.background.withAlphaComponent(0.3)

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        tableView.addSubview(view)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            view.removeFromSuperview()
        }
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func createThemeSetting() -> SettingsPresenter.Selection {
        return SettingsPresenter.Selection(
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

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = presenter.item(for: indexPath)
        switch item {
        case let item as SettingsPresenter.Selection:
            item.handler()
        case let item as SettingsPresenter.Link:
            UIApplication.shared.open(item.link)
        case let item as SettingsPresenter.Destructive:
            item.handler()
        default:
            return
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfItems(for: section)
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch presenter.item(for: indexPath) {
        case is SettingsPresenter.Selection:
            let cell = tableView.dequeueReusableCell(withClass: SettingsSelectionTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case is SettingsPresenter.Link:
            let cell = tableView.dequeueReusableCell(withClass: SettingsLinkTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case is SettingsPresenter.Destructive:
            let cell = tableView.dequeueReusableCell(withClass: SettingsDestructiveTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case is SettingsPresenter.Toggle:
            let cell = tableView.dequeueReusableCell(withClass: SettingsToggleTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        default:
            fatalError("unknown item")
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.title(for: section)
    }
}
