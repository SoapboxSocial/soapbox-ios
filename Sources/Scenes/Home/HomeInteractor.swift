import Foundation

protocol HomeInteractorOutput {}

class HomeInteractor: HomeViewControllerOutput {
    private let output: HomeInteractorOutput

    init(output: HomeInteractorOutput) {
        self.output = output
    }
}
