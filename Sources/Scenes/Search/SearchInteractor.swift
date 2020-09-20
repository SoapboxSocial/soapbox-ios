import Foundation

protocol SearchInteractorOutput {}

class SearchInteractor {
    private let output: SearchInteractorOutput

    init(output: SearchInteractorOutput) {
        self.output = output
    }
}
