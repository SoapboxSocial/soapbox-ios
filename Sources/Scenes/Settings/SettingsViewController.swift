import UIKit

class SettingsViewController: UIViewController {
    private let presenter = SettingsPresenter()

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(cellWithClass: SettingsLinkTableViewCell.self)
        view.register(cellWithClass: SettingsSelectionTableViewCell.self)
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

        presenter.set(links: [
            SettingsPresenter.Link(name: NSLocalizedString("contact_us", comment: ""), link: URL(string: "mailto:support@soapbox.social")!),
            SettingsPresenter.Link(name: NSLocalizedString("terms", comment: ""), link: URL(string: "https://soapbox.social/terms")!),
            SettingsPresenter.Link(name: NSLocalizedString("privacy", comment: ""), link: URL(string: "https://soapbox.social/privacy")!),
        ])

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

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func createThemeSetting() -> SettingsPresenter.Appearance {
        SettingsPresenter.Appearance(
            name: NSLocalizedString("theme", comment: ""),
            handler: {
                let sheet = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                sheet.addAction(UIAlertAction(title: NSLocalizedString("system", comment: ""), style: .default, handler: { _ in
                    UserDefaults.standard.set(Theme.system.rawValue, forKey: UserDefaultsKeys.theme)
                }))

                sheet.addAction(UIAlertAction(title: NSLocalizedString("dark", comment: ""), style: .default, handler: { _ in
                    UserDefaults.standard.set(Theme.dark.rawValue, forKey: UserDefaultsKeys.theme)
                }))

                sheet.addAction(UIAlertAction(title: NSLocalizedString("light", comment: ""), style: .default, handler: { _ in
                    UserDefaults.standard.set(Theme.light.rawValue, forKey: UserDefaultsKeys.theme)
                }))

                // @TODO THIS DOESN'T WORK
                sheet.willDismissHandler = {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

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
        switch presenter.sectionType(for: indexPath.section) {
        case .appearance:
            tableView.deselectRow(at: indexPath, animated: true)
            let selection = presenter.item(for: indexPath, ofType: SettingsPresenter.Appearance.self)
            selection.handler()
        case .links:
            tableView.deselectRow(at: indexPath, animated: true)
            let link = presenter.item(for: indexPath, ofType: SettingsPresenter.Link.self)
            UIApplication.shared.open(link.link)
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
        switch presenter.sectionType(for: indexPath.section) {
        case .appearance:
            let cell = tableView.dequeueReusableCell(withClass: SettingsSelectionTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .links:
            let cell = tableView.dequeueReusableCell(withClass: SettingsLinkTableViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.title(for: section)
    }
}
