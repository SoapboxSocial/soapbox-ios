import Foundation

class SettingsPresenter {
    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case appearance
        case links
    }

    struct Section {
        let type: SectionType
        let title: String?
        var data: [Any]
    }

    struct Link {
        let name: String
        let link: URL
    }

    struct Appearance {
        let name: String
        let handler: () -> Void
        let value: () -> String
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    func sectionType(for sectionIndex: Int) -> SectionType {
        return dataSource[sectionIndex].type
    }

    func item<T: Any>(for index: IndexPath, ofType _: T.Type) -> T {
        return dataSource[index.section].data[index.row] as! T
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
        guard let selection = dataSource[indexPath.section].data[indexPath.row] as? Appearance else {
            return
        }

        item.textLabel?.text = selection.name
        item.selection.text = selection.value()
    }

    func set(links: [Link]) {
        dataSource.append(Section(type: .links, title: nil, data: links))
    }

    func set(appearance: [Appearance]) {
        dataSource.append(Section(type: .appearance, title: NSLocalizedString("appearance", comment: ""), data: appearance))
    }
}
