import UserNotifications

extension UNUserNotificationCenter {
    var notificationSettings: UNNotificationSettings {
        var settings: UNNotificationSettings!

        let group = DispatchGroup()
        group.enter()
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { s in
            settings = s
            group.leave()
        })

        group.wait()

        return settings
    }
}
