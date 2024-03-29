import Foundation

protocol ProfilePresenterOutput {
    func display(profile: APIClient.Profile)
    func display(personal profile: APIClient.Profile)
    func didUnfollow()
    func didFollow()
    func didBlock()
    func didUnblock()
    func displayError(title: String, description: String?)
    func display(stories: [APIClient.Story])
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

    func display(stories: [APIClient.Story]) {
        output.display(stories: stories)
    }

    func displayBlocked() {
        output.didBlock()
    }

    func displayUnblocked() {
        output.didUnblock()
    }
}
