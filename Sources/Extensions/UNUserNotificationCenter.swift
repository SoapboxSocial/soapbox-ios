import UserNotifications

extension UNUserNotificationCenter {
    var notificationSettings: UNNotificationSettings {
        var settings: UNNotificationSettings!

        let group = DispatchGroup()
        group.enter()
        UNUserNotificationCenter.current().getNotificationSettings { value in
            settings = value
            group.leave()
        }

        group.wait()

        return settings
    }
}
