import Foundation

protocol SearchInteractorOutput {
    func didFetch(users: [APIClient.User])
    func failedToFetch()
}

class SearchInteractor {
    private let output: SearchInteractorOutput
    private let api: APIClient
    
    private var keyword: String?
    private var start = 0
    private let limit = 10

    init(output: SearchInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }
}

extension SearchInteractor: SearchViewControllerOutput {
    func search(_ keyword: String) {
        self.keyword = keyword
        api.search(keyword, limit: limit, start: start, callback: { result in
            switch result {
            case .failure:
                self.output.failedToFetch()
            case let .success(users):
                self.output.didFetch(users: users)
            }
        })
    }
    
    func nextPage() {
        start = start + limit
        
        guard let term = keyword else {
            return
        }
        
        
        // @TODO
        api.search(term, limit: limit, start: start, callback: { result in
            switch result {
            case .failure:
//                self.output.endRefreshing()
            case let .success(users):
//                self.output.didFetch(users: users)
            }
        })
    }
}
