//
//  NotificationManager.swift
//  Voicely
//
//  Created by Dean Eigenmann on 13.08.20.
//

import UIKit

protocol NotificationManagerDelegate {
    func deviceTokenWasSet()
    func deviceTokenFailedToSet()
}

class NotificationManager {
    static let shared = NotificationManager()

    private var api = APIClient()

    var delegate: NotificationManagerDelegate?

    func setDeviceToken(_ token: Data) {
        let tokenParts = token.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        api.addDevice(token: token) { _ in
            // @todo
            self.delegate?.deviceTokenWasSet()
        }
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
