import Foundation

protocol ProfilePresenterOutput {
    func display(profile: APIClient.Profile)
    func display(personal profile: APIClient.Profile)
}

class ProfilePresenter: ProfileInteractorOutput {
    private var output: ProfilePresenterOutput

    init(output: ProfilePresenterOutput) {
        self.output = output
    }

    func displayPersonal(profile: APIClient.Profile) {
        output.display(personal: profile)
    }

    func display(profile: APIClient.Profile) {
        output.display(profile: profile)
    }
}
