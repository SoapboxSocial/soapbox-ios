import Foundation

protocol SearchResultsPresenterOutput {
    func display(users: [APIClient.User])
    func display(nextPage: [APIClient.User])
    func display(groups: [APIClient.Group])
    func display(nextPageGroups: [APIClient.Group])
    func displaySearchError()
}

class SearchResultsPresenter {
    private var output: SearchResultsPresenterOutput

    init(output: SearchResultsPresenterOutput) {
        self.output = output
    }
}

extension SearchResultsPresenter: SearchResultsInteractorOutput {
    func didFetch(users: [APIClient.User]) {
        output.display(users: users)
    }

    func didFetch(nextPage: [APIClient.User]) {
        output.display(nextPage: nextPage)
    }

    func didFetch(groups: [APIClient.Group]) {
        output.display(groups: groups)
    }

    func didFetch(nextPageGroups: [APIClient.Group]) {
        output.display(nextPageGroups: nextPageGroups)
    }

    func failedToFetch() {
        output.displaySearchError()
    }
}
