import AlamofireImage
import UIKit

class HomeCollectionPresenter {
    var currentRoom: Int?

    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case roomList
        case storiesList
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

    private(set) var hasOwnStory = true

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
            var amount = section.data.count + 1
            if hasOwnStory {
                amount += 1
            }

            return amount
        default:
            return section.data.count
        }
    }

    func configure(item: StoryCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        var offset = 1
        if hasOwnStory {
            offset = 2
        }

        guard let story = section.data[indexPath.row - offset] as? APIClient.StoryFeed else {
            print("Error getting active user for indexPath: \(indexPath)")
            return
        }

        let user = story.user

        if let image = user.image, image != "" {
            item.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
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

    func set(hasOwnStory: Bool) {
        self.hasOwnStory = hasOwnStory
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
