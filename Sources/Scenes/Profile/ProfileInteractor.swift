import Foundation

protocol ProfileInteractorOutput {
    func displayPersonal(profile: APIClient.Profile)
    func display(profile: APIClient.Profile)
    func display(groups: [APIClient.Group])
    func displayUnfollowed()
    func displayFollowed()
    func displayError()
    func display(moreGroups groups: [APIClient.Group])
    func display(stories: [APIClient.Story])
}

class ProfileInteractor {
    private let output: ProfileInteractorOutput
    private let api: APIClient
    private let user: Int

    private var groupOffset = 0
    private let groupLimit = 10

    init(output: ProfileInteractorOutput, api: APIClient, user: Int) {
        self.output = output
        self.api = api
        self.user = user
    }
}

extension ProfileInteractor: ProfileViewControllerOutput {
    func loadMoreGroups() {
        let nextOffset = groupOffset + groupLimit

        api.groups(id: user, limit: groupLimit, offset: nextOffset, callback: { result in
            switch result {
            case .failure: break
            case let .success(groups):
                self.output.display(moreGroups: groups)
                self.groupOffset = nextOffset
            }
        })
    }

    func loadData() {
        api.user(id: user) { result in
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

        api.groups(id: user, limit: groupLimit, offset: groupOffset, callback: { result in
            switch result {
            case .failure: break
            case let .success(groups):
                self.output.display(groups: groups)
            }
        })

        api.stories(user: user, callback: { result in
            switch result {
            case .failure: break
            case let .success(stories):
                self.output.display(stories: stories)
            }
        })
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
