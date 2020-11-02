import Foundation

protocol GroupCreationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?)
    func transitionTo(state: GroupCreationInteractor.State, id: Int?)
}

class GroupCreationPresenter: GroupCreationInteractorOutput {
    let output: GroupCreationPresenterOutput

    init(output: GroupCreationPresenterOutput) {
        self.output = output
    }

    func present(error: GroupCreationInteractor.Error) {
        switch error {
        case .invalidName:
            output.displayError(.normal, title: NSLocalizedString("invalid_name", comment: ""), description: nil)
        case .failedToCreate:
            output.displayError(
                .normal,
                title: NSLocalizedString("failed_to_create_group", comment: ""),
                description: NSLocalizedString("please_try_again_later", comment: "")
            )
        }
    }

    func present(state: GroupCreationInteractor.State, id: Int?) {
        output.transitionTo(state: state, id: id)
    }
}
