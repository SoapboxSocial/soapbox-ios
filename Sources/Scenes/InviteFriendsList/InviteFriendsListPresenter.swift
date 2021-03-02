import Foundation

protocol InviteFriendsListPresenterOutput {
    func present(users: [APIClient.User])
    func present(success: String)
}

class InviteFriendsListPresenter: InviteFriendsListInteractorOutput {
    var output: InviteFriendsListPresenterOutput

    init(output: InviteFriendsListPresenterOutput) {
        self.output = output
    }

    func didFetch(users: [APIClient.User]) {
        output.present(users: users)
    }

    func presentSuccess(user: APIClient.User) {
        output.present(success: user.displayName)
    }
}
