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
        dataSource.append(Section(type: .storiesList, title: nil, subtitle: nil, data: []))
        dataSource.append(Section(type: .noRooms, title: nil, subtitle: nil, data: []))
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

    func set(feed: Feed) {
        dataSource.removeAll()

        dataSource.insert(Section(type: .storiesList, title: nil, subtitle: nil, data: feed.stories), at: 0)

        hasOwnStory = feed.ownStory.count > 0

        var rooms = feed.rooms

        // @TODO move actives to the bottom cause layout estimate issue0 &
        if feed.actives.count > 0 {
            if rooms.count > 0 {
                var room: RoomAPIClient.Room
                if let id = currentRoom, let r = rooms.first(where: { $0.id == id }) {
                    room = r
                } else {
                    room = rooms.sorted(by: { $0.members.count > $1.members.count }).first!
                }

                rooms.removeAll(where: { $0.id == room.id })
                dataSource.append(Section(type: .topRoom, title: NSLocalizedString("rooms", comment: ""), subtitle: nil, data: [room]))
            }

            dataSource.append(
                Section(
                    type: .activeUserList,
                    title: NSLocalizedString("online_right_now", comment: ""),
                    subtitle: NSLocalizedString("start_a_room_with_them", comment: ""),
                    data: feed.actives
                )
            )
        }

        if feed.rooms.count == 0 {
            dataSource.append(Section(type: .noRooms, title: nil, subtitle: nil, data: []))
            return
        }

        dataSource.append(Section(type: .roomList, title: feed.actives.count == 0 ? NSLocalizedString("rooms", comment: "") : nil, subtitle: nil, data: rooms))
    }

    func has(section: SectionType) -> Bool {
        return dataSource.contains(where: { $0.type == section })
    }

    func index(of section: SectionType) -> Int? {
        return dataSource.firstIndex(where: { $0.type == section })
    }

    private func removeRooms() {
        dataSource.removeAll(where: { $0.type == .roomList })

        if dataSource.contains(where: { $0.type == .noRooms || $0.type == .topRoom }) {
            return
        }

        dataSource.append(Section(type: .noRooms, title: nil, subtitle: nil, data: []))
    }
}
