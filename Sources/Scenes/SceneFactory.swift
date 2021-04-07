import Foundation

class SceneFactory {
    static func createSearchViewController() -> SearchViewController {
        let viewController = SearchViewController()
        let presenter = SearchPresenter(output: viewController)

        let interactor = SearchInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        return viewController
    }

    static func createUserViewController(id: Int, title: String, userListFunc: @escaping APIClient.UserListFunc) -> UserListViewController {
        let viewController = UserListViewController()
        viewController.title = title
        let presenter = UserListPresenter(output: viewController)

        let interactor = UserListInteractor(output: presenter, user: id, userListFunc: userListFunc)
        viewController.output = interactor

        return viewController
    }

    static func createProfileViewController(id: Int? = nil, username: String? = nil) -> ProfileViewController {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter(output: viewController)

        let interactor = ProfileInteractor(output: presenter, api: APIClient(), user: id, username: username)
        viewController.output = interactor

        return viewController
    }

    static func createNotificationsViewController() -> NotificationsViewController {
        let viewController = NotificationsViewController()
        let presenter = NotificationsPresenter(output: viewController)

        let interactor = NotificationsInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        return viewController
    }

    static func createInviteFriendsListViewController(room: Room) -> InviteFriendsListViewController {
        let viewController = InviteFriendsListViewController()
        let presenter = InviteFriendsListPresenter(output: viewController)

        let interactor = InviteFriendsListInteractor(output: presenter, api: APIClient(), room: room)
        viewController.output = interactor

        return viewController
    }

    static func createAuthenticationViewController() -> AuthenticationViewController {
        let viewController = AuthenticationViewController()
        let presenter = AuthenticationPresenter(output: viewController)

        let interactor = AuthenticationInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        return viewController
    }

    static func createSettingsViewController() -> SettingsViewController {
        return SettingsViewController()
    }
}
