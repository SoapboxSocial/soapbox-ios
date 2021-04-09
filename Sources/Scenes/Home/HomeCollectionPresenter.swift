import AlamofireImage
import UIKit

class HomeCollectionPresenter {
    var currentRoom: String?

    private var dataSource = [Section]()

    enum SectionType: Int, CaseIterable {
        case topRoom
        case roomList
        case storiesList
        case activeUserList
        case noRooms
    }

    struct Section {
        let type: SectionType
        let title: String?
        let subtitle: String?
        var data: [Any]
    }

    var numberOfSections: Int {
        return dataSource.count
    }

    private(set) var hasOwnStory = false

    init() {
        set(stories: [])
        set(actives: [
            APIClient.ActiveUser(id: 1, displayName: "Dean", username: "test", image: "", room: nil),
            APIClient.ActiveUser(id: 1, displayName: "poop", username: "test", image: "", room: nil),
            APIClient.ActiveUser(id: 1, displayName: "poop", username: "test", image: "", room: nil),
            APIClient.ActiveUser(id: 1, displayName: "poop", username: "test", image: "", room: nil),
            APIClient.ActiveUser(id: 1, displayName: "poop", username: "test", image: "", room: nil),
            APIClient.ActiveUser(id: 1, displayName: "poop", username: "test", image: "", room: nil),
        ])
        set(rooms: [])
    }

    func title(for sectionIndex: Int) -> String? {
        return dataSource[sectionIndex].title
    }

    func subtitle(for sectionIndex: Int) -> String? {
        return dataSource[sectionIndex].subtitle
    }

    func sectionType(for sectionIndex: Int) -> SectionType {
        return dataSource[sectionIndex].type
    }

    func item<T: Any>(for index: IndexPath, ofType _: T.Type) -> T {
        let section = dataSource[index.section]

        // @TODO NOT SURE IF PRETTY
        var item = index.item
        if T.self == APIClient.StoryFeed.self {
            item -= 1

            if hasOwnStory {
                item -= 1
            }
        }

        return section.data[item] as! T
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
        guard let room = section.data[indexPath.row] as? RoomAPIClient.Room else {
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

    func configure(item: CollectionViewCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let user = section.data[indexPath.row] as? APIClient.ActiveUser else {
            print("Error getting room for indexPath: \(indexPath)")
            return
        }

        item.image.leftAnchor.constraint(equalTo: item.leftAnchor).isActive = true

        item.title.text = user.displayName
        item.subtitle.text = "@" + user.username
    }

    func set(topRoom: RoomAPIClient.Room) {
        dataSource.removeAll(where: { $0.type == .topRoom })

        var index = 0
        if has(section: .storiesList) {
            index = 1
        }

        dataSource.insert(Section(type: .topRoom, title: NSLocalizedString("rooms", comment: ""), subtitle: nil, data: [topRoom]), at: index)
    }

    func set(rooms: [RoomAPIClient.Room]) {
        if rooms.isEmpty {
            removeRooms()
            return
        }

        dataSource.removeAll(where: { $0.type == .roomList || $0.type == .noRooms })
        dataSource.append(Section(type: .roomList, title: "", subtitle: nil, data: rooms))
    }

    func set(stories: [APIClient.StoryFeed]) {
        dataSource.removeAll(where: { $0.type == .storiesList })
        dataSource.insert(Section(type: .storiesList, title: nil, subtitle: nil, data: stories), at: 0)
    }

    func set(hasOwnStory: Bool) {
        self.hasOwnStory = hasOwnStory
    }

    func set(actives: [APIClient.ActiveUser]) {
        dataSource.append(Section(type: .activeUserList, title: "Online right now", subtitle: "Start a room with them", data: actives))
    }

    func has(section: SectionType) -> Bool {
        return dataSource.contains(where: { $0.type == section })
    }

    private func removeRooms() {
        dataSource.removeAll(where: { $0.type == .roomList })

        if dataSource.contains(where: { $0.type == .noRooms }) {
            return
        }

        dataSource.append(Section(type: .noRooms, title: nil, subtitle: nil, data: []))
    }
}
