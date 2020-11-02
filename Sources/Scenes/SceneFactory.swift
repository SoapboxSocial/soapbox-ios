import Foundation

class SceneFactory {
    static func createSearchViewController() -> SearchViewController {
        let viewController = SearchViewController()
        let presenter = SearchPresenter(output: viewController)

        let interactor = SearchInteractor(output: presenter, api: APIClient())
        viewController.output = interactor

        return viewController
    }

    static func createFollowerViewController(id: Int, userListFunc: @escaping APIClient.FollowerListFunc) -> FollowerListViewController {
        let viewController = FollowerListViewController()
        let presenter = FollowerListPresenter(output: viewController)

        let interactor = FollowerListInteractor(output: presenter, user: id, userListFunc: userListFunc)
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
}
