//
//  NotificationManager.swift
//  Voicely
//
//  Created by Dean Eigenmann on 13.08.20.
//

import UIKit

protocol NotificationManagerDelegate {
    func deviceTokenWasSet(_ token: Data)
    func deviceTokenFailedToSet()
}

class NotificationManager {
    static let shared = NotificationManager()

    private var deviceToken: Data?

    var delegate: NotificationManagerDelegate?

    func setDeviceToken(_ data: Data) {
        deviceToken = data
        delegate?.deviceTokenWasSet(data)
    }

    func failedToSetToken() {
        delegate?.deviceTokenFailedToSet()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
