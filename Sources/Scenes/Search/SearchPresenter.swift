import Foundation

protocol SearchPresenterOutput {
    func display(users: [APIClient.User])
    func display(groups: [APIClient.Group])
    func displayMore(users: [APIClient.User])
    func displayMore(groups: [APIClient.Group])
    func displaySearchError()
}

class SearchPresenter {
    private var output: SearchPresenterOutput

    init(output: SearchPresenterOutput) {
        self.output = output
    }
}

extension SearchPresenter: SearchInteractorOutput {
    func didFetch(groups: [APIClient.Group]) {
        output.display(groups: groups)
    }

    func didFetch(users: [APIClient.User]) {
        output.display(users: users)
    }

    func didFetchMore(users: [APIClient.User]) {
        output.displayMore(users: users)
    }

    func didFetchMore(groups: [APIClient.Group]) {
        output.displayMore(groups: groups)
    }

    func failedToFetch() {
        output.displaySearchError()
    }
}
