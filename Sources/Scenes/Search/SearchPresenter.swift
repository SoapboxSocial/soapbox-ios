import Foundation

protocol SearchPresenterOutput {
    func display(users: [APIClient.User])
    func display(nextPage: [APIClient.User])
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

    func didFetch(nextPage: [APIClient.User]) {
        output.display(nextPage: nextPage)
    }

    func failedToFetch() {
        output.displaySearchError()
    }
}
