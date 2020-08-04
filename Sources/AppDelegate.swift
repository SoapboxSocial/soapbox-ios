//
//  AppDelegate.swift
//  voicely
//
//  Created by Dean Eigenmann on 21.07.20.
//  Copyright © 2020 Dean Eigenmann. All rights reserved.
//

import UIKit
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let keychain = Keychain(service: "com.voicely.voicely")
        if let token = keychain[string: "token"], let expiry = keychain[string: "expiry"], (Int(expiry) ?? 0) > Int(Date().timeIntervalSince1970) {
            openLoggedInState()
            window?.makeKeyAndVisible()
            return true
        }

        let navigation = UINavigationController(rootViewController: LoginViewController())
        navigation.navigationBar.isHidden = true

        window!.rootViewController = navigation
        window?.makeKeyAndVisible()

        return true
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
}
