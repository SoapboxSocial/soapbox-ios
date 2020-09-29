import Foundation

protocol ProfileInteractorOutput {
    func displayPersonal(profile: APIClient.Profile)
    func display(profile: APIClient.Profile)
    func displayUnfollowed()
    func displayFollowed()
    func displayError()
}

class ProfileInteractor {
    private let output: ProfileInteractorOutput
    private let api: APIClient
    private let user: Int

    init(output: ProfileInteractorOutput, api: APIClient, user: Int) {
        self.output = output
        self.api = api
        self.user = user
    }
}

extension ProfileInteractor: ProfileViewControllerOutput {
    func loadData() {
        api.user(id: user) { result in
            switch result {
            case .failure:
                self.output.displayError()
            case let .success(user):
                if self.user == UserDefaults.standard.integer(forKey: "id") {
                    self.output.displayPersonal(profile: user)
                    UserStore.store(image: user.image, displayName: user.displayName)
                    return
                }

                self.output.display(profile: user)
            }
        }
    }

    func follow() {
        api.follow(id: user, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayFollowed()
            }
        })
    }

    func unfollow() {
        api.unfollow(id: user, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayUnfollowed()
            }
        })
    }
}
