import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func didFetch(nextPage: [APIClient.User])
    func failedToFetch()
}

class SearchInteractor {
    private let output: SearchInteractorOutput
    private let api: APIClient

    private var keyword: String?
    private var offset = 0
    private let limit = 10

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        self.keyword = keyword
        api.search(keyword, limit: limit, offset: offset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(users):
                self.output.didFetch(users: users)
            }
        })
    }

    func nextPage() {
        let nextOffset = offset + limit

        guard let term = keyword else {
            return
        }

        // @TODO
        api.search(term, limit: limit, offset: nextOffset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(users):
                self.offset = nextOffset
                self.output.didFetch(nextPage: users)
            }
        })
    }
}
