import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func failedToFetch()
}

class SearchInteractor {
    private let output: SearchInteractorOutput
    private let api: APIClient

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        api.search(keyword, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(users):
                self.output.didFetch(users: users)
            }
        })
    }
}
