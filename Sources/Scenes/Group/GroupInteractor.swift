import Foundation

protocol GroupInteractorOutput {
    func present(group: APIClient.Group)
    func present(inviter: APIClient.User)
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

                if group.isInvited ?? false {
                    self.loadInvite()
                }

                self.output.present(group: group)
            }
        })
    }

    private func loadInvite() {
        api.getInvite(id: group, callback: { result in
            switch result {
            case .failure: break
            case let .success(inviter):
                self.output.present(inviter: inviter)
            }
        })
    }
}
