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

        // let viewController = RoomListViewControllerOld(api: APIClient())

        let viewController = RoomListViewController()
        let presenter = RoomListPresenter(output: viewController)
        let interactor = RoomListInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        let navigation = NavigationViewController(rootViewController: viewController)
        // viewController.delegate = navigation

        window!.rootViewController = navigation
        window?.makeKeyAndVisible()

        return true
    }
}
