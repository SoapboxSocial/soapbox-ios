import Foundation

protocol ProfileInteractorOutput {
    func displayPersonal(profile: APIClient.Profile)
    func display(profile: APIClient.Profile)
    func displayUnfollowed()
    func displayFollowed()
    func displayError()
    func display(stories: [APIClient.Story])
    func displayBlocked()
    func displayUnblocked()
}

class ProfileInteractor {
    private let output: ProfileInteractorOutput
    private let api: APIClient
    private var user: Int?
    private var username: String?

    init(output: ProfileInteractorOutput, api: APIClient, user: Int? = nil, username: String? = nil) {
        self.output = output
        self.api = api
        self.user = user
        self.username = username
    }
}

extension ProfileInteractor: ProfileViewControllerOutput {
    func loadData() {
        if user != nil {
            return loadById()
        }

        if username != nil {
            return loadByUsername()
        }
    }

    private func loadById() {
        guard let id = user else {
            return
        }

        api.user(id: id) { result in
            switch result {
            case .failure:
                self.output.displayError()
            case let .success(user):
                if self.user == UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
                    self.output.displayPersonal(profile: user)
                    return
                }

                self.output.display(profile: user)
            }
        }

        loadStories()
    }

    private func loadByUsername() {
        guard let name = username else {
            return
        }

        api.user(name: name) { result in
            switch result {
            case .failure:
                self.output.displayError()
            case let .success(user):
                self.user = user.id

                self.loadStories()

                if self.user == UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
                    self.output.displayPersonal(profile: user)
                    return
                }

                self.output.display(profile: user)
            }
        }
    }

    private func loadStories() {
        guard let id = user else {
            return
        }

        api.stories(user: id, callback: { result in
            switch result {
            case .failure: break
            case let .success(stories):
                self.output.display(stories: stories)
            }
        })
    }

    func follow() {
        guard let id = user else {
            return
        }

        api.follow(id: id, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayFollowed()
            }
        })
    }

    func unfollow() {
        guard let id = user else {
            return
        }

        api.unfollow(id: id, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayUnfollowed()
            }
        })
    }

    func block() {
        guard let id = user else {
            return
        }

        api.block(user: id, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayBlocked()
            }
        })
    }

    func unblock() {
        guard let id = user else {
            return
        }

        api.unblock(user: id, callback: { result in
            switch result {
            case .failure:
                self.output.displayError()
            case .success:
                self.output.displayUnblocked()
            }
        })
    }
}
