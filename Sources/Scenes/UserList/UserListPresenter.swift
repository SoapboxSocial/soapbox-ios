import Foundation

protocol UserListPresenterOutput {
    func displayError(title: String, description: String?)
    func display(users: [APIClient.User])
}

class UserListPresenter: UserListInteractorOutput {
    private var output: UserListPresenterOutput

    init(output: UserListPresenterOutput) {
        self.output = output
    }

    func present(users: [APIClient.User]) {
        output.display(users: users)
    }

    func presentGeneralError() {
        output.displayError(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            description: NSLocalizedString("please_try_again_later", comment: "")
        )
    }
}
