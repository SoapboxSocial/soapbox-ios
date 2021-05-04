import UIKit

protocol SettingsItem {
    var name: String { get }
}

class SettingsTableView: UITableView {
    var sections = [Section]()

    enum SectionType: Int, CaseIterable {
        case appearance
        case links
        case deleteAccount
    }

    struct Link: SettingsItem {
        let name: String
        let link: URL
    }

    struct Selection: SettingsItem {
        let name: String
        let handler: () -> Void
        let value: () -> String
    }

    struct Destructive: SettingsItem {
        let name: String
        let handler: () -> Void
    }

    struct Toggle: SettingsItem {
        let name: String
        let isOn: () -> Bool
        let handler: (Bool) -> Void
    }

    struct Plain: SettingsItem {
        let name: String
        let handler: () -> Void
    }

    struct Section {
        let title: String?
        var data: [SettingsItem]
    }

    init() {
        super.init(frame: .zero, style: .insetGrouped)
        translatesAutoresizingMaskIntoConstraints = false

        register(cellWithClass: SettingsLinkTableViewCell.self)
        register(cellWithClass: SettingsSelectionTableViewCell.self)
        register(cellWithClass: SettingsToggleTableViewCell.self)
        register(cellWithClass: SettingsDestructiveTableViewCell.self)
        register(cellWithClass: SettingsPlainTableViewCell.self)

        backgroundColor = .background

        dataSource = self
        delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func item(for index: IndexPath) -> SettingsItem {
        return sections[index.section].data[index.row]
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        return sections[sectionIndex].data.count
    }

    func title(for sectionIndex: Int) -> String? {
        return sections[sectionIndex].title
    }

    func configure(item: SettingsLinkTableViewCell, for indexPath: IndexPath) {
        guard let link = sections[indexPath.section].data[indexPath.row] as? Link else {
            return
        }

        item.textLabel?.text = link.name
    }

    func configure(item: SettingsSelectionTableViewCell, for indexPath: IndexPath) {
        guard let selection = sections[indexPath.section].data[indexPath.row] as? Selection else {
            return
        }

        item.textLabel?.text = selection.name
        item.selection.text = selection.value()
    }

    func configure(item: SettingsToggleTableViewCell, for indexPath: IndexPath) {
        guard let toggle = sections[indexPath.section].data[indexPath.row] as? Toggle else {
            return
        }

        item.textLabel?.text = toggle.name
        item.toggle.isOn = toggle.isOn()
        item.handler = toggle.handler
    }

    func configure(item: SettingsPlainTableViewCell, for indexPath: IndexPath) {
        guard let plain = sections[indexPath.section].data[indexPath.row] as? Plain else {
            return
        }

        item.textLabel?.text = plain.name
    }

    func configure(item: SettingsDestructiveTableViewCell, for indexPath: IndexPath) {
        guard let selection = sections[indexPath.section].data[indexPath.row] as? Destructive else {
            return
        }

        item.textLabel?.text = selection.name
    }
}

extension SettingsTableView: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch item(for: indexPath) {
        case is Selection:
            let cell = tableView.dequeueReusableCell(withClass: SettingsSelectionTableViewCell.self, for: indexPath)
            configure(item: cell, for: indexPath)
            return cell
        case is Link:
            let cell = tableView.dequeueReusableCell(withClass: SettingsLinkTableViewCell.self, for: indexPath)
            configure(item: cell, for: indexPath)
            return cell
        case is Destructive:
            let cell = tableView.dequeueReusableCell(withClass: SettingsDestructiveTableViewCell.self, for: indexPath)
            configure(item: cell, for: indexPath)
            return cell
        case is Toggle:
            let cell = tableView.dequeueReusableCell(withClass: SettingsToggleTableViewCell.self, for: indexPath)
            configure(item: cell, for: indexPath)
            return cell
        case is Plain:
            let cell = tableView.dequeueReusableCell(withClass: SettingsPlainTableViewCell.self, for: indexPath)
            configure(item: cell, for: indexPath)
            return cell
        default:
            fatalError("unknown item")
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return title(for: section)
    }
}

extension SettingsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = item(for: indexPath)
        switch item {
        case let item as Selection:
            item.handler()
        case let item as Link:
            UIApplication.shared.open(item.link)
        case let item as Destructive:
            item.handler()
        case let item as Plain:
            item.handler()
        default:
            return
        }
    }
}
