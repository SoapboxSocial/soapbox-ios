import Foundation

protocol GroupCreationInteractorOutput {}

class GroupCreationInteractor {
    private let output: GroupCreationInteractorOutput

    init(output: GroupCreationInteractorOutput) {
        self.output = output
    }
}
