import AlamofireImage
import UIKit

class SearchCollectionPresenter {
    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case groupList
        case userList
    }

    struct Section {
        let type: SectionType
        let title: String
        let data: [Any]
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    func sectionTitle(for sectionIndex: Int) -> String {
        return dataSource[sectionIndex].title
    }

    func sectionType(for sectionIndex: Int) -> SectionType {
        return dataSource[sectionIndex].type
    }

    func item<T: Any>(for index: IndexPath, ofType _: T.Type) -> T {
        let section = dataSource[index.section]
        return section.data[index.row] as! T
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        return dataSource[sectionIndex].data.count
    }

    func configure(item: GroupSearchCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let group = section.data[indexPath.row] as? APIClient.Group else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.layer.mask = nil
        item.layer.cornerRadius = 0

        if indexPath.item == 0 {
            item.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        }

        if indexPath.item == (section.data.count - 1) {
            item.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        }

        if indexPath.item == 0, section.data.count == 1 {
            item.layer.mask = nil
            item.layer.cornerRadius = 30
            item.layer.masksToBounds = true
        }

        item.name.text = group.name

        if let image = group.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }
    }

    func configure(item: UserCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let user = section.data[indexPath.row] as? APIClient.User else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.layer.mask = nil
        item.layer.cornerRadius = 0

        if indexPath.item == 0 {
            item.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        }

        if indexPath.item == (section.data.count - 1) {
            item.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        }

        if indexPath.item == 0, section.data.count == 1 {
            item.layer.mask = nil
            item.layer.cornerRadius = 30
            item.layer.masksToBounds = true
        }

        item.displayName.text = user.displayName
        item.username.text = "@" + user.username

        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func set(groups: [APIClient.Group]) {
        dataSource.removeAll(where: { $0.type == .groupList })

        if groups.isEmpty {
            return
        }

        dataSource.insert(Section(type: .groupList, title: NSLocalizedString("groups", comment: ""), data: groups), at: 0)
    }

    func set(users: [APIClient.User]) {
        dataSource.removeAll(where: { $0.type == .userList })

        if users.isEmpty {
            return
        }

        dataSource.append(Section(type: .userList, title: NSLocalizedString("users", comment: ""), data: users))
    }
}
