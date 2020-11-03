import UIKit

class FollowingNotificationCell: NotificationCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        body = NSLocalizedString("started_following_you", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
