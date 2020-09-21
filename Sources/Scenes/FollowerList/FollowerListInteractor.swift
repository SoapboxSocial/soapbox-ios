import Foundation

protocol FollowerListInteractorOutput {
    func presentGeneralError()
    func present(users: [APIClient.User])
}

class FollowerListInteractor: FollowerListViewControllerOutput {
    private let output: FollowerListInteractorOutput
    private let userListFunc: APIClient.FollowerListFunc
    private let user: Int

    init(output: FollowerListInteractorOutput, user: Int, userListFunc: @escaping APIClient.FollowerListFunc) {
        self.output = output
        self.user = user
        self.userListFunc = userListFunc
    }

    func loadFollowers() {
        userListFunc(user) { result in
            switch result {
            case .failure:
                self.output.presentGeneralError()
            case let .success(list):
                self.output.present(users: list)
            }
        }
    }
}
