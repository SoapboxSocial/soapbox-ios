import Foundation

protocol InviteFriendsListPresenterOutput {
    func present(users: [APIClient.User])
}

class InviteFriendsListPresenter: InviteFriendsListInteractorOutput {
    var output: InviteFriendsListPresenterOutput

    init(output: InviteFriendsListPresenterOutput) {
        self.output = output
    }

    func didFetch(users: [APIClient.User]) {
        output.present(users: users)
    }
}
