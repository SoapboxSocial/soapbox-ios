import Foundation

protocol SettingsItem {
    var name: String { get }
}

class SettingsPresenter {
    private var dataSource = [Section]()

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

    struct Section {
        let title: String?
        var data: [SettingsItem]
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    func item(for index: IndexPath) -> SettingsItem {
        return dataSource[index.section].data[index.row]
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        return dataSource[sectionIndex].data.count
    }

    func title(for sectionIndex: Int) -> String? {
        return dataSource[sectionIndex].title
    }

    func configure(item: SettingsLinkTableViewCell, for indexPath: IndexPath) {
        guard let link = dataSource[indexPath.section].data[indexPath.row] as? Link else {
            return
        }

        item.textLabel?.text = link.name
    }

    func configure(item: SettingsSelectionTableViewCell, for indexPath: IndexPath) {
        guard let selection = dataSource[indexPath.section].data[indexPath.row] as? Selection else {
            return
        }

        item.textLabel?.text = selection.name
        item.selection.text = selection.value()
    }

    func configure(item: SettingsDestructiveTableViewCell, for indexPath: IndexPath) {
        guard let selection = dataSource[indexPath.section].data[indexPath.row] as? Destructive else {
            return
        }

        item.textLabel?.text = selection.name
    }

    func set(links: [Link]) {
        dataSource.append(Section(title: nil, data: links))
    }

    func set(appearance: [Selection]) {
        dataSource.append(Section(title: NSLocalizedString("appearance", comment: ""), data: appearance))
    }

    func set(deleteAccount: Destructive) {
        dataSource.append(Section(title: nil, data: [deleteAccount]))
    }
}
