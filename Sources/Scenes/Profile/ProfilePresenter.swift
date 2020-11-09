import Foundation

protocol ProfilePresenterOutput {
    func display(profile: APIClient.Profile)
    func display(groups: [APIClient.Group])
    func display(personal profile: APIClient.Profile)
    func didUnfollow()
    func didFollow()
    func displayError(title: String, description: String?)
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

    func displayFollowed() {
        output.didFollow()
    }

    func displayUnfollowed() {
        output.didUnfollow()
    }

    func displayError() {
        output.displayError(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            description: NSLocalizedString("please_try_again_later", comment: "")
        )
    }

    func display(groups: [APIClient.Group]) {
        output.display(groups: groups)
    }
}
