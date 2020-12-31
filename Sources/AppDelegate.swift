import KeychainAccess
import NotificationBannerSwift
import Siren
import Swifter
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

        let loggedIn = isLoggedIn()

        window!.rootViewController = { () -> UIViewController in
//            if loggedIn {
//                return createLoggedIn()
//            } else {
            createLoginView()
//            }
        }()

        window?.makeKeyAndVisible()

        updateNotify()

        if !loggedIn {
            return true
        }

        NotificationManager.shared.requestAuthorization()

        if let notification = options?[.remoteNotification] as? [String: AnyObject] {
            launchWith(notification: notification)
        }

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Swifter.handleOpenURL(url, callbackURL: URL(string: "soapbox://")!)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive || application.applicationState == .background {
            guard let notification = userInfo as? [String: AnyObject] else { return }
            launchWith(notification: notification)
        }
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }

        switch components.path {
        case "/login-pin":
            return handlePinURL(components: components)
        case "/room":
            return handleRoomURL(components: components)
        default:
            return false
        }
    }

    private func handlePinURL(components: NSURLComponents) -> Bool {
        guard let param = components.queryItems?.first(where: { $0.name == "pin" }), let pin = param.value else {
            return false
        }

        guard let nav = window?.rootViewController as? UINavigationController else {
            return false
        }

        guard let auth = nav.visibleViewController as? AuthenticationViewController else {
            return false
        }

        return auth.inject(pin: pin)
    }

    private func handleRoomURL(components: NSURLComponents) -> Bool {
        guard let param = components.queryItems?.first(where: { $0.name == "id" }), let str = param.value else {
            return false
        }

        guard let room = Int(str) else {
            return false
        }

        guard let nav = window?.rootViewController as? NavigationViewController else {
            return false
        }

        nav.didSelect(room: room)
        return true
    }

    func transitionToLoginView() {
        window!.set(
            rootViewController: createLoginView(),
            options: UIWindow.TransitionOptions(direction: .fade, style: .easeOut)
        )
    }

    func createLoggedIn() -> UIViewController {
        let viewController = HomeViewController()
        let presenter = HomePresenter()
        presenter.output = viewController

        let nav = NavigationViewController(rootViewController: viewController)
        let interactor = HomeInteractor(output: presenter, service: ServiceFactory.createRoomService(), controller: nav, api: APIClient())
        viewController.output = interactor

        nav.roomControllerDelegate = interactor

        return nav
    }

    func createLoginView() -> UIViewController {
        let navigation = UINavigationController(rootViewController: SceneFactory.createAuthenticationViewController())
        navigation.navigationBar.isHidden = true

        return navigation
    }

    private func updateNotify() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(
            majorUpdateRules: .critical,
            minorUpdateRules: .annoying,
            patchUpdateRules: .default,
            revisionUpdateRules: Rules(promptFrequency: .immediately, forAlertType: .option)
        )

        siren.wail()
    }

    private func isLoggedIn() -> Bool {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("no identifier")
        }

        let keychain = Keychain(service: identifier)
        if keychain[string: "token"] == nil {
            return false
        }

        guard let expiry = keychain[string: "expiry"] else {
            return false
        }

        if (Int(expiry) ?? 0) <= Int(Date().timeIntervalSince1970) {
            return false
        }

        if UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) == 0 {
            return false
        }

        return true
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let nav = self.window?.rootViewController as? NavigationViewController else {
            return completionHandler(true)
        }

        switch shortcutItem.type {
        case "NEW_ROOM":
            nav.createRoom(name: nil, isPrivate: false, group: nil)
        case "NEW_PRIVATE_ROOM":
            nav.createRoom(name: nil, isPrivate: true, group: nil)
        default:
            break
        }

        completionHandler(true)
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

        let notification = GrowingNotificationBanner(title: notification.request.content.body, style: .success)

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
            case "GROUP_INVITE":
                guard let id = args["id"] as? Int else {
                    return
                }

                nav.pushViewController(SceneFactory.createGroupViewController(id: id), animated: true)
            default:
                break
            }
        }
    }
}
