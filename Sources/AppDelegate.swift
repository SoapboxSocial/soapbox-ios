//
//  AppDelegate.swift
//  voicely
//
//  Created by Dean Eigenmann on 21.07.20.
//  Copyright © 2020 Dean Eigenmann. All rights reserved.
//

import KeychainAccess
import UIKit
import UIWindowTransitions
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let controller = { () -> UIViewController in
            if isLoggedIn() {
                return createLoggedIn()
            } else {
                return createLoginView()
            }
        }()

        window!.rootViewController = controller
        window?.makeKeyAndVisible()

        registerForPushNotifications()

        return true
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            debugPrint("Permissions: \(granted)")
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
        let keychain = Keychain(service: "com.voicely.voicely")
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
