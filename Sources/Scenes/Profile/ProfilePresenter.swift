import Foundation

protocol ProfilePresenterOutput {
    func display(profile: APIClient.Profile)
}

class ProfilePresenter: ProfileInteractorOutput {
    private var output: ProfilePresenterOutput

    init(output: ProfilePresenterOutput) {
        self.output = output
    }

    func displayPersonal(profile _: APIClient.Profile) {}

    func display(profile: APIClient.Profile) {
        output.display(profile: profile)
    }
}
