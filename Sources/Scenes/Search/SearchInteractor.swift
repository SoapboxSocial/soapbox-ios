import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didFetch(groups: [APIClient.Group])
    func didFetchMore(users: [APIClient.User])
    func didFetchMore(groups: [APIClient.Group])
    func failedToFetch()
}

class SearchInteractor {
    private let output: SearchInteractorOutput
    private let api: APIClient

    private let initialLimit = 3

    private let limit = 10
    private var offsets = [APIClient.SearchIndex: Int]()
    private var keyword: String?

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api

        offsets[.groups] = 0
        offsets[.users] = 0
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        self.keyword = keyword

        api.search(keyword, types: [.users, .groups], limit: initialLimit, offset: 0, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                self.offsets[.groups] = 0
                self.offsets[.users] = 0

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

    func loadMore(type: APIClient.SearchIndex) {
        guard let offset = offsets[type] else {
            return
        }

        var lastLimit = limit
        if offset == 0 {
            lastLimit = initialLimit
        }

        let nextOffset = offsets[type]! + lastLimit

        guard let keyword = self.keyword else {
            return
        }

        api.search(keyword, types: [type], limit: limit, offset: nextOffset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                self.offsets[type] = nextOffset

                switch type {
                case .groups:
                    self.output.didFetchMore(groups: response.groups ?? [])
                case .users:
                    self.output.didFetchMore(users: response.users ?? [])
                }
            }
        })
    }
}
