import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didFetch(groups: [APIClient.Group])
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
        api.search(keyword, types: [.users, .groups], limit: 3, offset: 0, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                if let groups = response.groups {
                    self.output.didFetch(groups: groups)
                } else {
                    self.output.didFetch(groups: [])
                }

                if let users = response.users {
                    self.output.didFetch(users: users)
                } else {
                    self.output.didFetch(users: [])
                }

                if response.users == nil, response.users == nil {
                    self.output.failedToFetch()
                }
            }
        })
    }
}
