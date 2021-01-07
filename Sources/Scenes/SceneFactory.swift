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

    static func createProfileViewController(id: Int) -> ProfileViewController {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter(output: viewController)

        let interactor = ProfileInteractor(output: presenter, api: APIClient(), user: id)
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

    static func createGroupCreationViewController() -> GroupCreationViewController {
        let viewController = GroupCreationViewController()
        let presenter = GroupCreationPresenter(output: viewController)

        let interactor = GroupCreationInteractor(output: presenter, api: APIClient())
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

    static func createGroupViewController(id: Int) -> GroupViewController {
        let viewController = GroupViewController()
        let presenter = GroupPresenter(output: viewController)

        let interactor = GroupInteractor(output: presenter, api: APIClient(), group: id)
        viewController.output = interactor

        return viewController
    }

    static func createInviteFriendsToGroupViewController(id: Int) -> InviteFriendsToGroupViewController {
        let viewController = InviteFriendsToGroupViewController()
        let presenter = InviteFriendsToGroupPresenter(output: viewController)

        let interactor = InviteFriendsToGroupInteractor(output: presenter, api: APIClient(), id: id)
        viewController.output = interactor

        return viewController
    }

    static func createSettingsViewController() -> SettingsViewController {
        return SettingsViewController()
    }
}
