import Foundation

class SettingsPresenter {
    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case links
    }

    struct Section {
        let type: SectionType
        let title: String
        var data: [Any]
    }

    struct Link {
        let name: String
        let link: URL
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

    func configure(item: SettingsLinkTableViewCell, for indexPath: IndexPath) {
        guard let link = dataSource[indexPath.section].data[indexPath.row] as? Link else {
            return
        }

        item.textLabel?.text = link.name
    }

    func set(links: [Link]) {
        dataSource.removeAll(where: { $0.type == .links })
        dataSource.append(Section(type: .links, title: "", data: links))
    }
}
