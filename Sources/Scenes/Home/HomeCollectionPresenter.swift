import Foundation

protocol SectionData {}

enum SectionType: Int, CaseIterable {
    case roomList
    case activeList
}

struct Section {
    let type: SectionType
    let data: [Any]
}

class HomeCollectionPresenter {
    var dataSource = [Section]()

    var numberOfSections: Int {
        return dataSource.count
    }

    init() {
        dataSource.append(Section(type: .activeList, data: [1, 2, 3]))
    }

    func sectionType(for sectionIndex: Int) -> SectionType {
        return dataSource[sectionIndex].type
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        return dataSource[sectionIndex].data.count
    }

    func configure(item _: ActiveUserCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let room = section.data[indexPath.row] as? RoomState else {
            print("Error getting app for indexPath: \(indexPath)")
            return
        }
    }

    func configure(item: RoomCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let room = section.data[indexPath.row] as? RoomState else {
            print("Error getting app for indexPath: \(indexPath)")
            return
        }

        item.members = room.members

        item.title.text = {
            if room.name != "" {
                return room.name
            }

//            if let id = currentRoom, room.id == id {
//                return NSLocalizedString("current_room", comment: "")
//            }

            return NSLocalizedString("listen_in", comment: "")
        }()

//        if let id = currentRoom, room.id == id {
//            item.style = .current
//        } else {
//            item.style = .normal
//        }

        item.style = .normal
        item.visibility = room.visibility
    }
}
