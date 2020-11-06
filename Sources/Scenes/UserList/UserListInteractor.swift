import Foundation

protocol UserListInteractorOutput {
    func presentGeneralError()
    func present(users: [APIClient.User])
}

class UserListInteractor: UserListViewControllerOutput {
    private let output: UserListInteractorOutput
    private let userListFunc: APIClient.UserListFunc
    private let user: Int

    private var offset = 0
    private var limit = 10

    init(output: UserListInteractorOutput, user: Int, userListFunc: @escaping APIClient.UserListFunc) {
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
