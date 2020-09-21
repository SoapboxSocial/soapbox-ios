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
}
