//
//  AppDelegate.swift
//  voicely
//
//  Created by Dean Eigenmann on 21.07.20.
//  Copyright © 2020 Dean Eigenmann. All rights reserved.
//

import KeychainAccess
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        if isLoggedIn() {
            openLoggedInState()
            window?.makeKeyAndVisible()
            return true
        }

        showLoginScreen()
        window?.makeKeyAndVisible()

        return true
    }

    func showLoginScreen() {
        let navigation = UINavigationController(rootViewController: LoginViewController())
        navigation.navigationBar.isHidden = true

        window!.rootViewController = navigation
    }

    func transitionToLoggedInState(token: String, user: APIClient.User, expires: Int) {
        let keychain = Keychain(service: "com.voicely.voicely")
        try? keychain.set(token, key: "token")
        try? keychain.set(String(Int(Date().timeIntervalSince1970) + expires), key: "expiry")

        UserStore.store(user: user)

        openLoggedInState()
    }

    func openLoggedInState() {
        let viewController = RoomListViewController(api: APIClient())
        let nav = NavigationViewController(rootViewController: viewController)
        viewController.delegate = nav

        window!.rootViewController = nav
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
