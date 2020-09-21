import Foundation

protocol FollowerListPresenterOutput {
    func displayError(title: String, description: String?)
    func display(users: [APIClient.User])
}

class FollowerListPresenter: FollowerListInteractorOutput {
    private var output: FollowerListPresenterOutput

    init(output: FollowerListPresenterOutput) {
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
