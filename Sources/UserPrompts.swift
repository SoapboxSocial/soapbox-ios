import StoreKit
import UIKit

class UserPrompts {
    static func promptForReview(room: Room) -> Bool {
        let now = Date()

        let last = Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastReviewed)))
        let reviewInterval = Calendar.current.dateComponents([.month], from: last, to: now)
        guard let monthsSince = reviewInterval.month else {
            return false
        }

        let interval = Calendar.current.dateComponents([.minute], from: room.started, to: Date())
        guard let minutesInRoom = interval.minute else {
            return false
        }

        if !(minutesInRoom >= 5 && monthsSince >= 4 && room.maxMembers > 2) {
            return false
        }

        SKStoreReviewController.requestReview()
        UserDefaults.standard.set(Int(now.timeIntervalSince1970), forKey: UserDefaultsKeys.lastReviewed)

        return true
    }

    static func promptForNotificationsAfter(room: Room, on view: UIViewController) -> Bool {
        let settings = UNUserNotificationCenter.current().notificationSettings
        if settings.authorizationStatus != .denied {
            return false
        }

        let interval = Calendar.current.dateComponents([.minute], from: room.started, to: Date())
        guard let minutesInRoom = interval.minute else {
            return false
        }

        let now = Date()
        let last = Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastNotificationsAfterRoomPrompted)))
        let promptInterval = Calendar.current.dateComponents([.month], from: last, to: now)
        guard let monthsSince = promptInterval.month else {
            return false
        }

        let startup = Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastNotificationsStartupPrompted)))
        let startupInterval = Calendar.current.dateComponents([.hour], from: startup, to: now)
        guard let startupSince = startupInterval.hour else {
            return false
        }

        if !(minutesInRoom >= 5 && monthsSince > 2 && room.maxMembers > 2 && startupSince > 6) {
            return false
        }

        view.present(NotificationPromptViewController(.afterRoom), animated: true)
        UserDefaults.standard.set(Int(now.timeIntervalSince1970), forKey: UserDefaultsKeys.lastNotificationsAfterRoomPrompted)

        return true
    }

    static func promptForNotifications(onView view: UIViewController) -> Bool {
        let settings = UNUserNotificationCenter.current().notificationSettings
        if settings.authorizationStatus != .denied {
            return false
        }

        let prompted = UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastNotificationsStartupPrompted)
        if prompted > 0 {
            return false
        }

        view.present(NotificationPromptViewController(.startup), animated: true)
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: UserDefaultsKeys.lastNotificationsStartupPrompted)

        return true
    }
}
