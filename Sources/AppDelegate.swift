import KeychainAccess
import UIKit
import UIWindowTransitions
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let loggedIn = isLoggedIn()

        window!.rootViewController = { () -> UIViewController in
            if loggedIn {
                return createLoggedIn()
            } else {
                return createLoginView()
            }
        }()

        window?.makeKeyAndVisible()

        // @TODO: WHEN WE RE-RELEASE THE APP UNDER A DIFFERENT IDENTIFIER, WE CAN REMOVE THIS.
        // THIS IS HERE FOR BACKWARDS COMPATIBILITY.
        // WHAT WE WILL NEED IS INSTEAD SETTINGS PAGE WHERE PEOPLE CAN ENABLE / DISABLE NOTIFICATIONS.
        if !loggedIn {
            return true
        }

        NotificationManager.shared.requestAuthorization()

        if let notification = options?[.remoteNotification] as? [String: AnyObject] {
            launchWith(notification: notification)
        }

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive || application.applicationState == .background {
            guard let notification = userInfo as? [String: AnyObject] else { return }
            launchWith(notification: notification)
        }
    }

    func transitionToLoginView() {
        window?.setRootViewController(createLoginView(), options: UIWindow.TransitionOptions(direction: .fade, style: .easeOut))
    }

    func createLoggedIn() -> UIViewController {
        let viewController = RoomListViewController(api: APIClient())
        let nav = NavigationViewController(rootViewController: viewController)
        viewController.delegate = nav

        return nav
    }

    func createLoginView() -> UIViewController {
        let viewController = AuthenticationViewController()
        let presenter = AuthenticationPresenter(output: viewController)
        let interactor = AuthenticationInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        let navigation = UINavigationController(rootViewController: viewController)
        navigation.navigationBar.isHidden = true

        return navigation
    }

    private func isLoggedIn() -> Bool {
        let keychain = Keychain(service: "app.soapbox.soapbox")
        guard let _ = keychain[string: "token"] else {
            return false
        }

        guard let expiry = keychain[string: "expiry"] else {
            return false
        }

        if (Int(expiry) ?? 0) <= Int(Date().timeIntervalSince1970) {
            return false
        }

        if UserDefaults.standard.integer(forKey: "id") == 0 {
            return false
        }

        return true
    }
}

extension AppDelegate {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.setDeviceToken(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // @todo
        print("Failed to register: \(error)")
        NotificationManager.shared.failedToSetToken()
    }

    private func launchWith(notification: [String: AnyObject]) {
        DispatchQueue.global(qos: .background).async {
            guard let aps = notification["aps"] as? [String: AnyObject] else {
                return
            }

            guard let category = aps["category"] as? String else {
                return
            }

            guard let arguments = aps["arguments"] as? [String: AnyObject] else {
                return
            }

            guard let nav = self.window?.rootViewController as? NavigationViewController else {
                return
            }

            switch category {
            case "NEW_ROOM":
                guard let id = arguments["id"] as? Int else {
                    return
                }

                DispatchQueue.main.async {
                    nav.didSelectRoom(id: id)
                }
            case "NEW_FOLLOWER":
                guard let id = arguments["id"] as? Int else {
                    return
                }

                DispatchQueue.main.async {
                    nav.pushViewController(ProfileViewController(id: id), animated: true)
                }
            default:
                break
            }
        }
    }
}
