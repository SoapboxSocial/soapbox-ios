import Foundation

protocol InviteFriendsListInteractorOutput {
    func didFetch(users: [APIClient.User])
    func presentSuccess(user: APIClient.User)
}

class InviteFriendsListInteractor: InviteFriendsListViewControllerOutput {
    private let output: InviteFriendsListInteractorOutput
    private let api: APIClient
    private let room: Room

    private var users = [APIClient.User]()

    init(output: InviteFriendsListInteractorOutput, api: APIClient, room: Room) {
        self.output = output
        self.api = api
        self.room = room
    }

    func fetchFriends() {
        api.friends(id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)) { result in
            switch result {
            case .failure: break
            case let .success(users):
                self.users = users
                self.output.didFetch(users: users)
            }
        }
    }

    func didSelect(user: Int) {
        room.invite(user: user)

        guard let data = users.first(where: { $0.id == user }) else {
            return
        }

        output.presentSuccess(user: data)
    }
}
