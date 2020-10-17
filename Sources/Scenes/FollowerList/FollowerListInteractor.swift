import Foundation

protocol FollowerListInteractorOutput {
    func presentGeneralError()
    func present(users: [APIClient.User])
}

class FollowerListInteractor: FollowerListViewControllerOutput {
    private let output: FollowerListInteractorOutput
    private let userListFunc: APIClient.FollowerListFunc
    private let user: Int

    private var offset = 0
    private var limit = 10

    init(output: FollowerListInteractorOutput, user: Int, userListFunc: @escaping APIClient.FollowerListFunc) {
        self.output = output
        self.user = user
        self.userListFunc = userListFunc
    }

    func loadFollowers() {
        userListFunc(user, limit, offset) { result in
            switch result {
            case .failure:
                self.output.presentGeneralError()
            case let .success(list):
                self.offset = self.offset + self.limit
                self.output.present(users: list)
            }
        }
    }
}
