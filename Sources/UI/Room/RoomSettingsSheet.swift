import UIKit

class RoomSettingsSheet {
    static func show(forRoom room: Room, on view: UIViewController) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: NSLocalizedString("change_name", comment: ""), style: .default, handler: { _ in
            self.editRoomNameButtonTapped(room: room, view: view)
        }))

        if !room.state.hasGroup {
            sheet.addAction(createVisibilityToggle(room: room))
        }

        sheet.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

        view.present(sheet, animated: true)
    }

    private static func createVisibilityToggle(room: Room) -> UIAlertAction {
        let visibility = room.state.visibility
        var label = NSLocalizedString("make_private", comment: "")
        if visibility == .private {
            label = NSLocalizedString("make_public", comment: "")
        }

        return UIAlertAction(title: label, style: .destructive, handler: { _ in
            switch visibility {
            case .private:
                room.updateVisibility(.public)
            case .public:
                room.updateVisibility(.private)
            default:
                return
            }
        })
    }

    private static func editRoomNameButtonTapped(room: Room, view: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("enter_name", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField()

        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { [unowned alert] _ in
            let answer = alert.textFields![0]
            guard let text = answer.text else {
                return
            }

            room.rename(text)
        }

        alert.addAction(submitAction)

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        alert.addAction(cancel)

        view.present(alert, animated: true)
    }
}
