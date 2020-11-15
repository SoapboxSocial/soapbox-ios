import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didFetch(groups: [APIClient.Group])
    func failedToFetch()
}

class SearchInteractor {
    private let output: SearchInteractorOutput
    private let api: APIClient

    private var keyword: String?
    private var offset = 0
    private var limit = 10

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        self.keyword = keyword
        limit = 3
        offset = 0

        api.search(keyword, types: [.users, .groups], limit: limit, offset: offset, callback: { result in
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
