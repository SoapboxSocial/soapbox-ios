import Foundation

protocol SearchPresenterOutput {
    func display(users: [APIClient.User])
    func displaySearchError()
}

class SearchPresenter {
    private var output: SearchPresenterOutput

    init(output: SearchPresenterOutput) {
        self.output = output
    }
}

extension SearchPresenter: SearchInteractorOutput {
    func didFetch(users: [APIClient.User]) {
        output.display(users: users)
    }

    func failedToFetch() {
        output.displaySearchError()
    }
}
