import UserNotifications

class LocalNotificationService {
    static func send(title: String? = nil, subtitle: String? = nil, body: String? = nil) {
        let content = UNMutableNotificationContent()

        if let title = title {
            content.title = title
        }

        if let subtitle = subtitle {
            content.subtitle = subtitle
        }

        if let body = body {
            content.body = body
        }

        content.sound = .default

        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
