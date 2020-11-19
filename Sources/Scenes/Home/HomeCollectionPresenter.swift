import AlamofireImage
import UIKit

class HomeCollectionPresenter {
    var currentRoom: Int?

    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case roomList
        case activeList
        case groupList
        case noRooms
    }

    struct Section {
        let type: SectionType
        let title: String
        var data: [Any]
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    init() {
        set(groups: []) // @TODO MAYBE HAVE A FIRST ITEM?
        set(rooms: [])
    }

    func title(for sectionIndex: Int) -> String {
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
        if section.type == .noRooms {
            return 1
        }

        if section.type == .groupList {
            return section.data.count + 1
        }

        return section.data.count
    }

    func configure(item: ActiveUserCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let user = section.data[indexPath.row] as? APIClient.ActiveUser else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.displayName.text = user.displayName.firstName()

        item.image.image = nil
        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func configure(item: GroupCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let group = section.data[indexPath.row - 1] as? APIClient.Group else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.name.text = group.name

        item.image.image = nil
        if let image = group.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
        }
    }

    func configure(item: RoomCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let room = section.data[indexPath.row] as? RoomState else {
            print("Error getting room for indexPath: \(indexPath)")
            return
        }

        item.title.text = {
            if room.name != "" {
                return room.name
            }

            if let id = currentRoom, room.id == id {
                return NSLocalizedString("current_room", comment: "")
            }

            return NSLocalizedString("listen_in", comment: "")
        }()

        if let id = currentRoom, room.id == id {
            item.style = .current
        } else {
            item.style = .normal
        }

        item.visibility = room.visibility
        item.members = room.members
    }

    func set(groups: [APIClient.Group]) {
        dataSource.removeAll(where: { $0.type == .groupList })

        var at = 0
        if has(section: .activeList) {
            at = 1
        }

        dataSource.insert(Section(type: .groupList, title: NSLocalizedString("groups", comment: ""), data: groups), at: at)
    }

    func add(groups: [APIClient.Group]) {
        guard let index = dataSource.firstIndex(where: { $0.type == .groupList }) else {
            return
        }

        dataSource[index].data.append(contentsOf: groups)
    }

    func set(rooms: [RoomState]) {
        if rooms.isEmpty {
            removeRooms()
            return
        }

        dataSource.removeAll(where: { $0.type == .roomList || $0.type == .noRooms })
        dataSource.append(Section(type: .roomList, title: NSLocalizedString("rooms", comment: ""), data: rooms))
    }

    func set(actives: [APIClient.ActiveUser]) {
        dataSource.removeAll(where: { $0.type == .activeList })

        if actives.isEmpty {
            return
        }

        dataSource.insert(Section(type: .activeList, title: "", data: actives), at: 0)
    }

    func index(of section: SectionType) -> Int? {
        return dataSource.firstIndex(where: { $0.type == section })
    }

    func has(section: SectionType) -> Bool {
        return dataSource.contains(where: { $0.type == section })
    }

    private func removeRooms() {
        dataSource.removeAll(where: { $0.type == .roomList })

        if dataSource.contains(where: { $0.type == .noRooms }) {
            return
        }

        dataSource.append(Section(type: .noRooms, title: "", data: []))
    }
}
