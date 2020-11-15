import Foundation

protocol SearchResultsInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didFetch(nextPage: [APIClient.User])
    func didFetch(groups: [APIClient.Group])
    func didFetch(nextPageGroups: [APIClient.Group])
    func failedToFetch()
}

class SearchResultsInteractor {
    private let output: SearchResultsInteractorOutput
    private let api: APIClient

    private var keyword: String
    private var type: APIClient.SearchIndex
    private var offset = 0
    private var limit = 10

    init(output: SearchResultsInteractorOutput, keyword: String, type: APIClient.SearchIndex, api: APIClient) {
        self.output = output
        self.api = api
        self.keyword = keyword
        self.type = type
    }
}

extension SearchResultsInteractor: SearchResultsViewControllerOutput {
    func search() {
        limit = 10
        offset = 0

        api.search(keyword, types: [type], limit: limit, offset: offset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):

                switch self.type {
                case .groups:
                    self.output.didFetch(groups: response.groups ?? [])
                case .users:
                    self.output.didFetch(users: response.users ?? [])
                }
            }
        })
    }

    func nextPage() {
        let nextOffset = offset + limit

        api.search(keyword, types: [type], limit: limit, offset: nextOffset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                self.offset = nextOffset

                switch self.type {
                case .groups:
                    self.output.didFetch(nextPageGroups: response.groups ?? [])
                case .users:
                    self.output.didFetch(nextPage: response.users ?? [])
                }
            }
        })
    }
}
