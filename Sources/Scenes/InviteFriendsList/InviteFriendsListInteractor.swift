import Foundation

protocol InviteFriendsListInteractorOutput {
    func didFetch(users: [APIClient.User])
}

class InviteFriendsListInteractor: InviteFriendsListViewControllerOutput {
    private let output: InviteFriendsListInteractorOutput
    private let api: APIClient

    init(output: InviteFriendsListInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }

    func fetchFriends() {
        api.friends { result in
            switch result {
            case .failure: break
            case let .success(users):
                self.output.didFetch(users: users)
            }
        }
    }

    func didSelect(user _: Int) {}
}
