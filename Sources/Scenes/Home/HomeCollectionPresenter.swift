import AlamofireImage
import UIKit

class HomeCollectionPresenter {
    var currentRoom: Int?

    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case roomList
        case storiesList
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
        set(stories: [])
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

        // @TODO NOT SURE IF PRETTY
        var row = index.row
        if T.self == APIClient.StoryFeed.self {
            row -= 1
        }

        return section.data[row] as! T
    }

    func numberOfItems(for sectionIndex: Int) -> Int {
        let section = dataSource[sectionIndex]
        switch section.type {
        case .noRooms:
            return 1
        case .storiesList:
            return section.data.count + 1
        default:
            return section.data.count
        }
    }

    func configure(item: StoryCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let story = section.data[indexPath.row - 1] as? APIClient.StoryFeed else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        let user = story.user

        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }
    }

    func configure(item: GroupCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let group = section.data[indexPath.row] as? APIClient.Group else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        item.name.text = group.name

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

        item.group = nil
        if room.hasGroup {
            item.group = room.group
        }
    }

    func set(groups: [APIClient.Group]) {
        dataSource.removeAll(where: { $0.type == .groupList })

        var at = 0
        if has(section: .storiesList) {
            at = 1
        }

        if groups.isEmpty {
            return
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

    func set(stories: [APIClient.StoryFeed]) {
        dataSource.removeAll(where: { $0.type == .storiesList })
        dataSource.insert(Section(type: .storiesList, title: "", data: stories), at: 0)
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
