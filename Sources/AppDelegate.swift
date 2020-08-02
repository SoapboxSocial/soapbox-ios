//
//  AppDelegate.swift
//  voicely
//
//  Created by Dean Eigenmann on 21.07.20.
//  Copyright © 2020 Dean Eigenmann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        // @todo we will probably want one api client

        // @todo check if logged in

        let viewController = RoomListViewController(api: APIClient())

        let navigation = UINavigationController(rootViewController: LoginViewController())
        navigation.navigationBar.isHidden = true

        window!.rootViewController = navigation
        window?.makeKeyAndVisible()

        return true
    }
}
