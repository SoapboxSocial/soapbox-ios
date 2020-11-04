import Foundation

protocol GroupPresenterOutput {
    func display(group: APIClient.Group)
}

class GroupPresenter: GroupInteractorOutput {
    private var output: GroupPresenterOutput

    init(output: GroupPresenterOutput) {
        self.output = output
    }

    func present(group: APIClient.Group) {
        output.display(group: group)
    }
}
