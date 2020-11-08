import Foundation

protocol InviteFriendsToGroupPresenterOutput {
    func present(users: [APIClient.User])
    func presentInviteSucceeded()
    func presentError()
}

class InviteFriendsToGroupPresenter: InviteFriendsToGroupInteractorOutput {
    var output: InviteFriendsToGroupPresenterOutput

    init(output: InviteFriendsToGroupPresenterOutput) {
        self.output = output
    }

    func didFetch(users: [APIClient.User]) {
        output.present(users: users)
    }

    func didInviteUsers() {
        output.presentInviteSucceeded()
    }

    func didFailToInvite() {
        output.presentError()
    }
}
