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
    private var limit = 10

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        self.keyword = keyword
        limit = 10
        offset = 0

        api.search(keyword, types: [.users], limit: limit, offset: offset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                guard let users = response.users else {
                    self.output.failedToFetch()
                    return
                }

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
        api.search(term, types: [.users], limit: limit, offset: nextOffset, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(response):
                self.offset = nextOffset
                guard let users = response.users else {
                    self.output.failedToFetch()
                    return
                }

                self.output.didFetch(nextPage: users)
            }
        })
    }
}
