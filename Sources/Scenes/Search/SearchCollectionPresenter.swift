import AlamofireImage
import UIKit

class SearchCollectionPresenter {
    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case userList
        case groupList
        case inviteFriends
    }

    struct Section {
        let type: SectionType
        let title: String
        var data: [Any]
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
        let section = dataSource[sectionIndex]

        if section.type == .inviteFriends {
            return 1
        }

        let count = dataSource[sectionIndex].data.count
        if count == 0 {
            return 0
        }

        return count + 1
    }

    func configure(item: CollectionViewCell, forGroup indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let group = section.data[indexPath.row] as? APIClient.Group else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.title.text = group.name

        item.image.image = nil
        if let image = group.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }
    }

    func configure(item: CollectionViewCell, forUser indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let user = section.data[indexPath.row] as? APIClient.User else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.title.text = user.displayName
        item.subtitle.text = "@" + user.username

        item.image.image = nil
        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func set(groups: [APIClient.Group]) {
        dataSource.removeAll(where: { $0.type == .groupList })

        if groups.isEmpty {
            return
        }

        dataSource.append(Section(type: .groupList, title: NSLocalizedString("groups", comment: ""), data: groups))
    }

    func set(users: [APIClient.User]) {
        dataSource.removeAll(where: { $0.type == .userList })

        if users.isEmpty {
            return
        }

        var index = 0
        if dataSource.first(where: { $0.type == .inviteFriends }) != nil {
            index = 1
        }

        dataSource.insert(Section(type: .userList, title: NSLocalizedString("users", comment: ""), data: users), at: index)
    }

    func append(users: [APIClient.User]) {
        guard let index = dataSource.firstIndex(where: { $0.type == .userList }) else {
            return
        }

        dataSource[index].data.append(contentsOf: users)
    }

    func append(groups: [APIClient.Group]) {
        guard let index = dataSource.firstIndex(where: { $0.type == .groupList }) else {
            return
        }

        dataSource[index].data.append(contentsOf: groups)
    }

    func appendInviteFriendsSection() {
        dataSource.insert(Section(type: .inviteFriends, title: "", data: []), at: 0)
    }

    func removeInviteFriendsSection() {
        dataSource.removeAll(where: { $0.type == .inviteFriends })
    }

    func index(of section: SectionType) -> Int? {
        return dataSource.firstIndex(where: { $0.type == section })
    }
}
