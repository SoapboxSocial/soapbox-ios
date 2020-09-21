import Foundation

protocol ProfileInteractorOutput {
    func displayPersonal(profile: APIClient.Profile)
    func display(profile: APIClient.Profile)
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
                break
            // @TODO
//                DispatchQueue.main.async {
//                    self.displayErrorBanner()
//                }
            case let .success(user):
                if self.user == UserDefaults.standard.integer(forKey: "id") {
                    self.output.displayPersonal(profile: user)
                    return
                }

                self.output.display(profile: user)
            }
        }
    }
}
