import AlamofireImage
import UIKit

protocol SectionData {}

struct Group {
    let title: String
}

enum SectionType: Int, CaseIterable {
    case roomList
    case activeList
    case groupList
    case noRooms
}

struct Section {
    let type: SectionType
    let title: String
    let data: [Any]
}

class HomeCollectionPresenter {
    var currentRoom: Int?

    private var dataSource = [Section]()

    var numberOfSections: Int {
        return dataSource.count
    }

    init() {
        set(groups: [Group(title: "woodworking"), Group(title: "crypto"), Group(title: "yolo"), Group(title: "Dialectic"), Group(title: "Mandela")])
        set(rooms: [])
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

        return section.data.count
    }

    func configure(item: ActiveUserCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let user = section.data[indexPath.row] as? APIClient.ActiveUser else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.displayName.text = user.displayName.firstName()
        item.username.text = "@" + user.username

        item.image.image = nil
        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func configure(item: GroupCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let group = section.data[indexPath.row] as? Group else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.name.text = group.title
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

    func set(groups: [Group]) {
        dataSource.removeAll(where: { $0.type == .groupList })

        if groups.isEmpty {
            return
        }

        dataSource.insert(Section(type: .groupList, title: "", data: groups), at: 0)
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

        dataSource.insert(Section(type: .activeList, title: "", data: actives), at: 1)
    }

    private func removeRooms() {
        dataSource.removeAll(where: { $0.type == .roomList })

        if dataSource.contains(where: { $0.type == .noRooms }) {
            return
        }

        dataSource.append(Section(type: .noRooms, title: "", data: []))
    }
}
