import Foundation

protocol GroupPresenterOutput {
    func display(group: APIClient.Group)
    func display(invite: APIClient.User)
}

class GroupPresenter: GroupInteractorOutput {
    private var output: GroupPresenterOutput

    init(output: GroupPresenterOutput) {
        self.output = output
    }

    func present(group: APIClient.Group) {
        output.display(group: group)
    }

    func present(inviter: APIClient.User) {
        output.display(invite: inviter)
    }
}
