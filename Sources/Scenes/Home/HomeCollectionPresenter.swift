import UIKit

protocol SectionData {}

enum SectionType: Int, CaseIterable {
    case roomList
    case activeList
}

struct Section {
    let type: SectionType
    let title: String
    let data: [Any]
}

class HomeCollectionPresenter {
    var dataSource = [Section]()

    var numberOfSections: Int {
        return dataSource.count
    }

    init() {
        dataSource.append(Section(type: .activeList, title: "", data: [1, 2, 3, 4, 5, 6, 7]))
        dataSource.append(Section(type: .roomList, title: "Rooms", data: [1, 2, 3, 4, 5, 6, 7]))
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

    class TestCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)

            backgroundColor = .clear

            contentView.backgroundColor = .foreground
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.layer.cornerRadius = 15
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func configure(item _: TestCell, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        guard let room = section.data[indexPath.row] as? RoomState else {
            print("Error getting app for indexPath: \(indexPath)")
            return
        }

//        item.members = room.members
//
//        item.title.text = {
//            if room.name != "" {
//                return room.name
//            }
//
        ////            if let id = currentRoom, room.id == id {
        ////                return NSLocalizedString("current_room", comment: "")
        ////            }
//
//            return NSLocalizedString("listen_in", comment: "")
//        }()
//
        ////        if let id = currentRoom, room.id == id {
        ////            item.style = .current
        ////        } else {
        ////            item.style = .normal
        ////        }
//
//        item.style = .normal
//        item.visibility = room.visibility
    }
}
