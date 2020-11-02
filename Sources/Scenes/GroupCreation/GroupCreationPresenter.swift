import Foundation

protocol GroupCreationPresenterOutput {}

class GroupCreationPresenter {
    let output: GroupCreationPresenterOutput

    init(output: GroupCreationPresenterOutput) {
        self.output = output
    }
}
