import Foundation

protocol InviteFriendsToGroupInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didInviteUsers()
    func didFailToInvite()
}

class InviteFriendsToGroupInteractor: InviteFriendsToGroupViewControllerOutput {
    private let output: InviteFriendsToGroupInteractorOutput
    private let api: APIClient
    private let id: Int

    init(output: InviteFriendsToGroupInteractorOutput, api: APIClient, id: Int) {
        self.output = output
        self.api = api
        self.id = id
    }

    func fetchFriends() {
        // @TODO: THIS SHOULD PROBABLY PULL SOME DATA OF FRIENDS WHO ARE NOT MEMBERS
        api.friends { result in
            switch result {
            case .failure: break
            case let .success(users):
                self.output.didFetch(users: users)
            }
        }
    }

    func invite(friends: [Int]) {
        api.inviteGroupMembers(id: id, users: friends, callback: { result in
            switch result {
            case .failure:
                self.output.didFailToInvite()
            case .success:
                self.output.didInviteUsers()
            }
        })
    }
}
