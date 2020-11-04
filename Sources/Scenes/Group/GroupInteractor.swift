import Foundation

protocol GroupInteractorOutput {
    func present(group: APIClient.Group)
}

class GroupInteractor: GroupViewControllerOutput {
    private let output: GroupInteractorOutput
    private let api: APIClient
    private let group: Int

    init(output: GroupInteractorOutput, api: APIClient, group: Int) {
        self.output = output
        self.api = api
        self.group = group
    }

    func loadData() {
        api.group(id: group, callback: { result in
            switch result {
            case .failure: break
            case let .success(group):
                self.output.present(group: group)
            }
        })
    }
}
