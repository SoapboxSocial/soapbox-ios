import KeychainAccess
import NotificationBannerSwift
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

        UNUserNotificationCenter.current().delegate = self

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .bold)], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .bold)]

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
        let viewController = HomeViewController()
        let presenter = HomePresenter()
        presenter.output = viewController

        let nav = NavigationViewController(rootViewController: viewController)
        let interactor = HomeInteractor(output: presenter, service: ServiceFactory.createRoomService(), controller: nav)
        viewController.output = interactor

        nav.roomControllerDelegate = interactor

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
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
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

extension AppDelegate: UNUserNotificationCenterDelegate {
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

            self.handleNotificationAction(for: category, args: arguments)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler _: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let aps = notification.request.content.userInfo["aps"] as? [String: AnyObject] else {
            return
        }

        guard let category = aps["category"] as? String else {
            return
        }

        guard let arguments = aps["arguments"] as? [String: AnyObject] else {
            return
        }

        let notification = NotificationBanner(title: notification.request.content.body, style: .success)

        notification.onTap = {
            self.handleNotificationAction(for: category, args: arguments)
        }

        notification.show()
    }

    private func handleNotificationAction(for category: String, args: [String: AnyObject]) {
        DispatchQueue.main.async {
            guard let nav = self.window?.rootViewController as? NavigationViewController else {
                return
            }

            switch category {
            case "NEW_ROOM", "ROOM_JOINED", "ROOM_INVITE":
                guard let id = args["id"] as? Int else {
                    return
                }

                nav.didSelect(room: id)
            case "NEW_FOLLOWER":
                guard let id = args["id"] as? Int else {
                    return
                }

                nav.pushViewController(SceneFactory.createProfileViewController(id: id), animated: true)
            default:
                break
            }
        }
    }
}
