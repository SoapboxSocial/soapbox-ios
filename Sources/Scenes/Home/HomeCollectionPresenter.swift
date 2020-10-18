import UIKit

protocol SectionData {}

enum SectionType: Int, CaseIterable {
    case roomList
    case activeList
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
        dataSource.append(Section(type: .activeList, title: "", data: [1, 2, 3, 4, 5, 6, 7]))
//        dataSource.append(Section(type: .noRooms, title: "", data: [Any]()))
        dataSource.append(Section(type: .roomList, title: "Rooms", data: [1, 2, 3, 4, 5, 6, 7]))
    }

    func sectionType(for sectionIndex: Int) -> SectionType {
        return dataSource[sectionIndex].type
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        let section = dataSource[sectionIndex]
        if section.type == .noRooms {
            return 1
        }

        return section.data.count
    }

    func configure(item _: ActiveUserCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let room = section.data[indexPath.row] as? RoomState else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
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

    func set(rooms: [RoomState]) {
        if rooms.isEmpty {
            removeRooms()
            return
        }

        dataSource.removeAll(where: { $0.type == .roomList })
        dataSource.append(Section(type: .roomList, title: NSLocalizedString("rooms", comment: ""), data: rooms))
    }

    func set(actives: [Int]) {
        if actives.isEmpty {
            dataSource.removeAll(where: { $0.type == .activeList })
        }

        dataSource.insert(Section(type: .activeList, title: "", data: actives), at: 0)
    }

    private func removeRooms() {
        dataSource.removeAll(where: { $0.type == .roomList })
        dataSource.append(Section(type: .noRooms, title: "", data: [Any]()))
    }
}
