import KeychainAccess
import Siren
import Swifter
import UIKit
import UIWindowTransitions
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var launchedShortcutItem: UIApplicationShortcutItem?

    private var launchedNotificationItem: [String: AnyObject]?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        UNUserNotificationCenter.current().delegate = self

        let loggedIn = isLoggedIn()

        window!.rootViewController = { () -> UIViewController in
            if loggedIn {
                return createLoggedIn()
            } else {
                return createLoginView()
            }
        }()

        setTheme()

        window?.makeKeyAndVisible()

        updateNotify()

        if !loggedIn {
            return true
        }

        NotificationManager.shared.requestAuthorization()

        if let notification = options?[.remoteNotification] as? [String: AnyObject] {
            launchedNotificationItem = notification
        }

        if let shortcutItem = options?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            return false
        }

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "twitter" {
            return Swifter.handleOpenURL(url, callbackURL: URL(string: "soapbox://")!)
        }

        if url.pathComponents.count < 2 {
            return false
        }

        switch url.host {
        case "room":
            return handleRoomURL(room: url.pathComponents[1])
        case "user":
            return handleUserURL(username: url.pathComponents[1])
        default:
            return false
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive || application.applicationState == .background {
            guard let notification = userInfo as? [String: AnyObject] else { return }
            launchedNotificationItem = notification
        }
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let incomingURL = userActivity.webpageURL else {
            return false
        }

        switch incomingURL.host {
        case "soapbox.social":
            return handleLegacySoapbox(incomingURL)
        case "soap.link":
            return handleSoapShortLinks(incomingURL)
        default:
            return false
        }
    }

    private func handleLegacySoapbox(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        let pathComponents = url.pathComponents
        if pathComponents.count < 2 {
            return false
        }

        switch pathComponents[1] {
        case "login-pin":
            return handlePinURL(components: components)
        case "room":
            if pathComponents.count < 3 {
                return false
            }

            return handleRoomURL(room: pathComponents[2])
        case "user":
            if pathComponents.count < 3 {
                return false
            }

            return handleUserURL(username: pathComponents[2])
        default:
            return false
        }
    }

    private func handleSoapShortLinks(_ url: URL) -> Bool {
        let pathComponents = url.pathComponents
        if pathComponents.count != 2 {
            return false
        }

        var path = pathComponents[1]

        if path.prefix(1) == "@" {
            path.remove(at: path.startIndex)
            return handleUserURL(username: path)
        }

        return handleRoomURL(room: path)
    }

    private func handlePinURL(components: URLComponents) -> Bool {
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

    private func handleRoomURL(room: String) -> Bool {
        guard let nav = window?.rootViewController as? NavigationViewController else {
            return false
        }

        nav.didSelect(room: room)
        return true
    }

    private func handleUserURL(username: String) -> Bool {
        guard let nav = window?.rootViewController as? NavigationViewController else {
            return false
        }

        nav.pushViewController(SceneFactory.createProfileViewController(username: username), animated: true)
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
        let interactor = HomeInteractor(output: presenter, controller: nav, api: APIClient(), room: RoomAPIClient())
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
            minorUpdateRules: .default,
            patchUpdateRules: .default,
            showAlertAfterCurrentVersionHasBeenReleasedForDays: 0
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
        completionHandler(handle(shortcutItem: shortcutItem))
    }

    func applicationDidBecomeActive(_: UIApplication) {
        if let notification = launchedNotificationItem {
            launchedNotificationItem = nil
            return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.launchWith(notification: notification)
            }
        }

        if let shortcut = launchedShortcutItem {
            launchedShortcutItem = nil
            return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                _ = self.handle(shortcutItem: shortcut)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let nav = self.window?.rootViewController as? NavigationViewController else {
                return
            }

            _ = nav.presentNotificiationPrompt()
        }
    }

    private func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let nav = self.window?.rootViewController as? NavigationViewController else {
            return false
        }

        switch shortcutItem.type {
        case "NEW_ROOM":
            nav.createRoom(name: nil, isPrivate: false, users: [])
        case "NEW_PRIVATE_ROOM":
            nav.createRoom(name: nil, isPrivate: true, users: []) // @TODO THIS IS A TAD BIT DUMB
        default:
            break
        }

        return true
    }

    func setTheme() {
        UIApplication.shared.windows.forEach { window in
            guard let theme = Theme(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.theme)) else {
                window.overrideUserInterfaceStyle = .unspecified
                return
            }

            switch theme {
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
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

            guard let uuid = aps["uuid"] as? String else {
                return
            }

            guard let category = aps["category"] as? String else {
                return
            }

            guard let arguments = aps["arguments"] as? [String: AnyObject] else {
                return
            }

            self.handleNotificationAction(uuid, for: category, args: arguments)
        }
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler _: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard let aps = notification.request.content.userInfo["aps"] as? [String: AnyObject] else {
            return
        }

        guard let uuid = aps["uuid"] as? String else {
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
            self.handleNotificationAction(uuid, for: category, args: arguments)
        }

        notification.show()
    }

    private func handleNotificationAction(_ uuid: String, for category: String, args: [String: AnyObject]) {
        APIClient().opened(notification: uuid, callback: { result in
            if case let .failure(err) = result {
                debugPrint("failed \(err)")
            }
        })

        DispatchQueue.main.async {
            guard let nav = self.window?.rootViewController as? NavigationViewController else {
                return
            }

            switch category {
            case "NEW_ROOM", "ROOM_JOINED", "ROOM_INVITE":
                guard let id = args["id"] as? String else {
                    return
                }

                nav.openPreviewDrawerFor(room: id)
            case "WELCOME_ROOM":
                guard let id = args["id"] as? String else {
                    return
                }

                nav.didSelect(room: id)
            case "NEW_FOLLOWER":
                guard let id = args["id"] as? Int else {
                    return
                }

                nav.pushViewController(SceneFactory.createProfileViewController(id: id), animated: true)
            case "FOLLOW_RECOMMENDATIONS":
                nav.visibleViewController?.present(FollowRecommendationsViewController(), animated: true)
            default:
                break
            }
        }
    }
}
