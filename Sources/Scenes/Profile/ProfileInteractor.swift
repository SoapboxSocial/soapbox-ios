import Foundation

protocol ProfileInteractorOutput {
    func displayPersonal(profile _: APIClient.Profile)
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
//                DispatchQueue.main.async {
//                    self.displayErrorBanner()
//                }
            case let .success(user):

                // @TODO IF ID == CURRENT USER DISPLAY PERSONAL
                self.output.display(profile: user)
            }
        }
    }
}
