import Foundation

class GroupNotificationCell: NotificationCell {
    var group: String! {
        didSet {
            let fmt = NSLocalizedString("invited_you_to_join", comment: "")
            body = String(format: fmt, group)
        }
    }
}
